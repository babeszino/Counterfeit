#extends Node2D
#
#@onready var player = $Player
#@onready var ui = $UI
#@onready var pause_menu = $UI/PauseMenu
#@onready var map_manager = get_node("/root/MapManager")
#
#var current_map = null
#
#
#func _ready() -> void:
	#randomize()
	#
	#call_deferred("load_next_map")
	#
	#if player and ui:
		#ui.set_player(player)
	#
	#if pause_menu:
		#print("PauseMenu found successfully!")
	#else:
		#print("ERROR: PauseMenu not found!")
#
#
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_cancel"):
		#print("Escape pressed")
		#if get_tree().paused:
			#print("game was paused, resuming")
			#pause_menu.resume_game()
		#else:
			#print("game was not paused, showing menu")
			#pause_menu.show_pause_menu()
#
#
#func get_next_map() -> int:
	#var next_index = (map_manager.current_map_index + 1) % map_manager.maps.size()
	#return next_index
#
#
#func load_next_map() -> void:
	#if map_manager:
		#var next_index = get_next_map()
		#map_manager.load_map(next_index)
#
#
#func spawn_player_at_marker() -> void:
	#var player = get_node_or_null("Player")
	#var spawn_point = current_map.get_node("SpawnPoints/PlayerSpawn")
	#
	#player.position = spawn_point.position
#
#
#func find_enemies(node) -> Array:
	#var enemies = []
	#
	#if node.is_in_group("enemy"):
		#enemies.append(node)
	#
	#for child in node.get_children():
		#enemies.append_array(find_enemies(child))
	#
	#return enemies
#
#
#func show_main_menu() -> void:
	#if map_manager:
		#get_tree().paused = false
		#
		#var old_map = get_node_or_null("current_map")
		#if old_map:
			#old_map.queue_free()
		#
		#var main_menu = load("res://scenes and scripts/main_menu.tscn").instantiate()
		#get_tree().root.add_child(main_menu)
		#
		#queue_free()
