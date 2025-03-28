extends Node

# Map data
var current_map_index : int = 0
var current_map_sequence_position : int = 0
var maps : Array = []
var maps_path : String = "res://scenes and scripts/maps/"
var randomized_map_indexes : Array = []

var completion_scene = preload("res://scenes and scripts/game_completed_screen.tscn")
var current_map_instance = null
var finish_door_container = null
var game_manager = null


func _ready() -> void:
	load_maps()
	game_manager = get_node_or_null("/root/GameManager")


func load_maps() -> void:
	var dir = DirAccess.open(maps_path)
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("map_layout") and file_name.ends_with(".tscn"):
			maps.append(maps_path + file_name)
		file_name = dir.get_next()
		
	maps.sort()


func randomize_map_order() -> void:
	randomized_map_indexes = []
	for i in range(maps.size()):
		randomized_map_indexes.append(i)
	
	randomized_map_indexes.shuffle()


func start_sequence() -> void:
	randomize_map_order()
	current_map_sequence_position = 0
	load_map(randomized_map_indexes[current_map_sequence_position])


func load_map(map_index) -> void:
	if map_index < 0 or map_index >= maps.size():
		return
	
	current_map_index = map_index
	
	# remove old map (if exists)
	cleanup_current_map()
	
	var map_scene = load(maps[map_index])
	if map_scene:
		current_map_instance = map_scene.instantiate()
		current_map_instance.name = "current_map"
		add_child(current_map_instance)
		
		await get_tree().process_frame
		
		position_player_on_map()
		reset_player_stats()
		spawn_enemies()
		
		await get_tree().process_frame
		
		find_door()


func load_next_map() -> void:
	current_map_sequence_position += 1
	if current_map_sequence_position >= randomized_map_indexes.size():
		show_game_completed_screen()
		return
	
	var next_map_index = randomized_map_indexes[current_map_sequence_position]
	load_map(next_map_index)


func position_player_on_map() -> void:
	if !game_manager or !game_manager.player or !current_map_instance:
		return
	
	var spawn_point = current_map_instance.get_node_or_null("SpawnPoints/PlayerSpawn")
	if spawn_point:
		game_manager.player.global_position = spawn_point.global_position


func spawn_enemies() -> void:
	if !game_manager or !current_map_instance:
		return
	
	var spawn_points = current_map_instance.get_node_or_null("SpawnPoints")
	
	for child in spawn_points.get_children():
		if "EnemySpawn" in child.name:
			var enemy = preload("res://scenes and scripts/enemy.tscn").instantiate()
			get_tree().root.add_child(enemy)
			enemy.global_position = child.global_position
			enemy.enemy_died.connect(game_manager.on_enemy_died)
			game_manager.register_enemy()


func find_door() -> void:
	if !current_map_instance:
		return
	
	finish_door_container = current_map_instance.get_node_or_null("FinishDoorContainer")


func reset_player_stats() -> void:
	if !game_manager or !game_manager.player:
		return
		
	var player = game_manager.player
	player.health_point.hp = 100
	
	var gun = player.get_node("Gun")
	gun.current_ammo = gun.max_ammo
	gun.is_reloading = false


func cleanup_current_map() -> void:
	if current_map_instance:
		current_map_instance.queue_free()
		current_map_instance = null


func show_game_completed_screen() -> void:
	if game_manager:
		game_manager.cleanup_entities()
	
	if current_map_instance:
		current_map_instance.queue_free()
		current_map_instance = null
	
	var game_completed_screen = completion_scene.instantiate()
	get_tree().root.add_child(game_completed_screen)
	
	current_map_sequence_position = 0
