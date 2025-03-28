extends Node

signal game_started
signal game_paused
signal game_resumed
signal game_over
signal enemy_killed

var player = null
var ui = null
var pause_menu = null
var enemy_count = 0
var game_active = false
var level_manager = null


func _ready() -> void:
	enemy_count = 0
	level_manager = get_node_or_null("/root/LevelManager")


func _input(event: InputEvent) -> void:
	if game_active and event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()


func start_game() -> void:
	enemy_count = 0
	
	emit_signal("game_started")
	
	player = preload("res://scenes and scripts/player.tscn").instantiate()
	get_tree().root.add_child(player)
	
	ui = preload("res://scenes and scripts/ui.tscn").instantiate()
	get_tree().root.add_child(ui)
	ui.set_player(player)
	pause_menu = ui.get_node("PauseMenu")
	
	if level_manager:
		level_manager.start_sequence()
	
	game_active = true


func restart_game() -> void:
	get_tree().paused = false
	
	enemy_count = 0
	
	cleanup_entities()
	
	start_game()


func pause_game() -> void:
	get_tree().paused = true
	
	if pause_menu:
		pause_menu.show()


func resume_game() -> void:
	get_tree().paused = false
	
	if pause_menu:
		pause_menu.hide()
	
	emit_signal("game_resumed")


func return_to_main_menu() -> void:
	get_tree().paused = false
	
	enemy_count = 0
	
	cleanup_entities()
	
	game_active = false
	
	var main_menu = load("res://scenes and scripts/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)


func quit_game() -> void:
	get_tree().quit()


func register_enemy() -> void:
	enemy_count += 1


func on_enemy_died() -> void:
	enemy_count -= 1
	emit_signal("enemy_killed")
	
	if enemy_count <= 0:
		if level_manager and level_manager.finish_door_container:
			level_manager.finish_door_container.open()


func cleanup_entities() -> void:
	if player:
		player.queue_free()
		player = null
	
	if ui:
		ui.queue_free()
		ui = null
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
	
	var bullets = get_tree().get_nodes_in_group("bullet")
	for bullet in bullets:
		bullet.queue_free()
	
	if level_manager:
		level_manager.cleanup_current_map()
