# ################
# core game controller script - felel a game state-ekert, a player-ert, az enemy-kert
# kezeli a game flow-t (start, pause, resume, cleanup)
# ################
extends Node

# signal-ok
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal enemy_killed

# node reference-ek
@onready var player_container = $"../../PlayerContainer"
@onready var level_manager = $"../LevelManager"
@onready var ui_container = $"../../UIContainer"
@onready var state_manager = $"../GameStateManager"
@onready var ui_manager = $"../UIManager"
@onready var enemy_manager = $"../EnemyManager"

# game state valtozok
var player = null
var enemy_count : int = 0
var game_active : bool = false


# input-ok kezelese (pause-olas/unpause-olas)
func _input(event: InputEvent) -> void:
	if game_active and event.is_action_pressed("ui_cancel"):
		if state_manager and state_manager.is_playing():
			pause_game()
		elif state_manager and state_manager.is_paused():
			resume_game()


# uj jatek inditasa
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


# jatek ujrainditasa
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


# jatek pause-olasa (szuneteltetese)
func pause_game() -> void:
	emit_signal("game_paused")
	
	if state_manager:
		state_manager.change_state(state_manager.GameState.PAUSED)


# jatek folytatasa (pause-olasbol)
func resume_game() -> void:
	emit_signal("game_resumed")
	
	if state_manager:
		state_manager.change_state(state_manager.GameState.PLAYING)


# visszateres a fomenube
func return_to_main_menu() -> void:
	get_tree().paused = false
	
	enemy_count = 0
	
	cleanup_entities()
	
	game_active = false
	
	if state_manager:
		state_manager.change_state(state_manager.GameState.MAIN_MENU)


# kilepes a jatekbol
func quit_game() -> void:
	get_tree().quit()


# uj enemy register-elese (enemy spawn-olasakor van meghivva)
func register_enemy() -> void:
	enemy_count += 1


# enemy halal kezelese
func on_enemy_died() -> void:
	enemy_count -= 1
	emit_signal("enemy_killed")
	
	if enemy_count <= 0:
		if level_manager and level_manager.finish_door_container:
			level_manager.finish_door_container.open()


# cleanup (player, enemy-k, projectile-ok (bullet, rocket), palyak)
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
