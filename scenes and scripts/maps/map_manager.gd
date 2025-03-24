extends Node

var current_map_index : int = 0
var maps : Array = []
var maps_path = "res://scenes and scripts/maps/"
var randomized_map_indexes : Array = []

var game_started : bool = false
var player
var ui_instance


func _ready():
	var dir = DirAccess.open(maps_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn") and file_name.begins_with("map_layout"):
				maps.append(maps_path + file_name)
			file_name = dir.get_next()
		
		maps.sort()


func start_game() -> void:
	game_started = true
	
	randomize_map_order()
	
	if ui_instance == null:
		ui_instance = preload("res://scenes and scripts/ui.tscn").instantiate()
		get_tree().root.add_child(ui_instance)
		print("UI instance created")
	
	# clear all enemies and bullets
	clear_entities()
	
	if player == null:
		player = preload("res://scenes and scripts/player.tscn").instantiate()
		get_tree().root.add_child(player)
		player.collision_layer = 2
		player.collision_mask = 1 | 4
		print("Player instance created and configured")
		
		if ui_instance != null:
			ui_instance.set_player(player)
			print("UI connected to player")
	
	current_map_index = 0
	load_map(randomized_map_indexes[current_map_index])


func clear_entities():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.queue_free()


func randomize_map_order() -> void:
	print("Randomizing map order...")
	
	randomized_map_indexes = []
	for i in range(maps.size()):
		randomized_map_indexes.append(i)
	
	randomized_map_indexes.shuffle()
	print("Randomized map order: ", randomized_map_indexes)


func load_map(map_index):
	if map_index < 0 or map_index >= maps.size():
		print("ERROR: Invalid map index")
		return
	
	print("Loading map: ", maps[map_index])
	
	current_map_index = map_index
	
	# remove old map if exists (if there are any)
	var old_map = get_node_or_null("current_map")
	if old_map:
		old_map.queue_free()
		await old_map.tree_exited
	
	clear_entities()
	
	var map_scene = load(maps[map_index])
	var map_instance = map_scene.instantiate()
	map_instance.name = "current_map"
	add_child(map_instance)
	
	await get_tree().process_frame
	
	if player != null:
		position_player_on_map(map_instance)
	else:
		print("ERROR: Player is null when positioning")
	
	spawn_enemies(map_instance)
	
	await get_tree().process_frame
	
	configure_enemy_detection()


func position_player_on_map(map_instance):
	var spawn_point = map_instance.get_node("SpawnPoints/PlayerSpawn")
	print("Spawning player at: ", spawn_point.global_position)
	player.global_position = spawn_point.global_position


func spawn_enemies(map_instance):
	var spawn_points_node = map_instance.get_node("SpawnPoints")
	
	for child in spawn_points_node.get_children():
		if "EnemySpawn" in child.name:
			var enemy = preload("res://scenes and scripts/enemy.tscn").instantiate()
			get_tree().root.add_child(enemy)
			enemy.collision_layer = 4  # layer 4 for enemies
			enemy.collision_mask = 1  # collide with world
			enemy.global_position = child.global_position
			print("Spawned enemy at: ", child.global_position)


func configure_enemy_detection():
	# wait for initialization
	await get_tree().create_timer(0.1).timeout
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	# player detection
	for enemy in enemies:
		var detection_zone = enemy.get_node("Functionality/PlayerDetectionZone")
		detection_zone.collision_layer = 0
		detection_zone.collision_mask = 2   # layer 2 to detect player
		
		for child in detection_zone.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.disabled = false


# WARNING: connect this function to a door signal later
func _on_door_player_entered():
	print("Player entered door, loading next map")
	current_map_index = (current_map_index + 1) % randomized_map_indexes.size()
	load_map(randomized_map_indexes[current_map_index])
