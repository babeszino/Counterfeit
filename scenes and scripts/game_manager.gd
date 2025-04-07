extends Node

signal game_started
signal game_paused
signal game_resumed
signal game_over
signal enemy_killed

@onready var player_container = $"../../PlayerContainer"
@onready var level_manager = $"../LevelManager"
@onready var ui_container = $"../../UIContainer"
@onready var state_manager = $"../GameStateManager"
@onready var ui_manager = $"../UIManager"
@onready var enemy_manager = $"../EnemyManager"

var player = null
var ui = null
var pause_menu = null
var enemy_count = 0
var game_active = false


func _ready() -> void:
	enemy_count = 0
	
	if ui_container.get_child_count() > 0:
		ui = ui_container.get_child(0)
		if ui and ui.has_node("PauseMenu"):
			pause_menu = ui.get_node("PauseMenu")


func _input(event: InputEvent) -> void:
	if game_active and event.is_action_pressed("ui_cancel"):
		if state_manager and state_manager.is_playing():
			pause_game()
		elif state_manager and state_manager.is_paused():
			resume_game()


func start_game() -> void:
	enemy_count = 0
	
	emit_signal("game_started")
	
	player = player_container.get_node("Player")
	if player:
		player.activate()
	
	if ui_manager:
		ui_manager.set_player(player)
		ui_manager.show_game_ui()
	
	var score_system = $"../ScoreSystem"
	if score_system:
		score_system.reset_score()
	
	if level_manager:
		level_manager.start_sequence()
	
	game_active = true
	
	var main_menu = get_node_or_null("/root/Main/Menu")
	if main_menu:
		main_menu.queue_free()


func restart_game() -> void:
	get_tree().paused = false
	
	enemy_count = 0
	
	cleanup_entities()
	
	var score_system = $"../ScoreSystem"
	if score_system:
		score_system.reset_score()
	
	if player:
		player.activate()
	
	start_game()


func pause_game() -> void:
	emit_signal("game_paused")
	
	if ui_manager:
		ui_manager.show_pause_menu()


func resume_game() -> void:
	emit_signal("game_resumed")
	
	if ui_manager:
		ui_manager.hide_pause_menu()


func return_to_main_menu() -> void:
	get_tree().paused = false
	
	enemy_count = 0
	
	cleanup_entities()
	
	game_active = false
	
	if ui_manager:
		ui_manager.hide_all_game_ui()
	
	if pause_menu:
		pause_menu.hide()
	
	var main = get_node("/root/Main")
	if main and main.has_method("show_main_menu"):
		main.show_main_menu()


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
		player.deactivate()
	
	if enemy_manager:
		enemy_manager.clear_enemies()
	
	var projectile_manager = $"../ProjectileManager"
	if projectile_manager:
		projectile_manager.clear_projectiles()
	
	if level_manager:
		level_manager.cleanup_current_map()
