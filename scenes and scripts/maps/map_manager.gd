extends Node

var current_map_index : int = 0
var current_map_sequence_position : int = 0
var maps : Array = []
var maps_path : String = "res://scenes and scripts/maps/"
var randomized_map_indexes : Array = []
var completion_scene = preload("res://scenes and scripts/game_completed_screen.tscn")

var player
var ui
var current_map_instance
var finish_door_container


func _ready() -> void:
	var dir = DirAccess.open(maps_path)
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("map_layout") and file_name.ends_with(".tscn"):
			maps.append(maps_path + file_name)
		file_name = dir.get_next()
		
	maps.sort()


func start_game() -> void:
	randomize_map_order()
	
	player = preload("res://scenes and scripts/player.tscn").instantiate()
	get_tree().root.add_child(player)
	player.collision_layer = 2
	player.collision_mask = 1 | 4 # 1 - world 4 - enemies
	
	ui = preload("res://scenes and scripts/ui.tscn").instantiate()
	get_tree().root.add_child(ui)
	ui.set_player(player)
	
	# reset sequence
	current_map_sequence_position = 0
	load_map(randomized_map_indexes[current_map_sequence_position])


func randomize_map_order() -> void:
	randomized_map_indexes = []
	for i in range(maps.size()):
		randomized_map_indexes.append(i)
	
	randomized_map_indexes.shuffle()


func load_map(map_index) -> void:
	if map_index < 0 or map_index >= maps.size():
		return
	
	current_map_index = map_index
	
	# remove old map (if exists)
	var old_map = get_node_or_null("current_map")
	if old_map:
		old_map.queue_free()
		await old_map.tree_exited
	
	var map_scene = load(maps[map_index])
	if map_scene:
		current_map_instance = map_scene.instantiate()
		current_map_instance.name = "current_map"
		add_child(current_map_instance)
		
		await get_tree().process_frame
		
		position_player_on_map(current_map_instance)
		reset_player_stats()
		spawn_enemies(current_map_instance)
		
		await get_tree().process_frame
		
		configure_enemy_detection()
		find_door(current_map_instance)


func position_player_on_map(map_instance) -> void:
	if map_instance == null:
		return
	
	var spawn_point = map_instance.get_node_or_null("SpawnPoints/PlayerSpawn")
	player.global_position = spawn_point.global_position


func spawn_enemies(map_instance) -> void:
	if map_instance == null:
		return
	
	var spawn_points_node = map_instance.get_node("SpawnPoints")
	
	for child in spawn_points_node.get_children():
		if "EnemySpawn" in child.name:
			var enemy = preload("res://scenes and scripts/enemy.tscn").instantiate()
			get_tree().root.add_child(enemy)
			enemy.collision_layer = 4  # layer 4 for enemies
			enemy.collision_mask = 1  # collide with world
			enemy.global_position = child.global_position


func configure_enemy_detection() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		var detection_zone = enemy.get_node("Functionality/PlayerDetectionZone")
		detection_zone.collision_layer = 0
		detection_zone.collision_mask = 2


func find_door(map_instance) -> void:
	if map_instance == null:
		return
	
	finish_door_container = map_instance.get_node("FinishDoorContainer")
	finish_door_container._ready()

func load_next_map() -> void:
	current_map_sequence_position += 1
	if current_map_sequence_position >= randomized_map_indexes.size():
		show_game_completed_screen()
		return
	
	var next_map_index = randomized_map_indexes[current_map_sequence_position]
	load_map(next_map_index)


func reset_player_stats() -> void:
	if player and is_instance_valid(player):
		player.health_point.hp = 100
		
		var gun = player.get_node("Gun")
		gun.current_ammo = gun.max_ammo
		gun.is_reloading = false


func _on_enemy_died() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		finish_door_container.open()


func show_game_completed_screen() -> void:
	if player != null:
		player.queue_free()
		player = null
	
	if ui != null:
		ui.queue_free()
		ui = null
	
	if current_map_instance != null:
		current_map_instance.queue_free()
		current_map_instance = null
	
	var game_completed_screen = completion_scene.instantiate()
	get_tree().root.add_child(game_completed_screen)
	
	current_map_sequence_position = 0
