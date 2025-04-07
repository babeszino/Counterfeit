extends Node

@onready var ui_container = $"../../UIContainer"
@onready var main_menu = $"../../UIContainer/MainMenu" 
@onready var hud = $"../../UIContainer/HUD"
@onready var pause_menu = $"../../UIContainer/PauseMenu"

@onready var game_manager = $"../GameManager"
@onready var state_manager = $"../GameStateManager"

var player_ref = null


func _ready() -> void:
	# Connect to state manager
	if state_manager:
		if not state_manager.is_connected("state_changed", Callable(self, "_on_game_state_changed")):
			state_manager.connect("state_changed", Callable(self, "_on_game_state_changed"))

	# Connect main menu signals
	if main_menu:
		if not main_menu.is_connected("start_game_pressed", Callable(self, "_on_start_game_pressed")):
			main_menu.connect("start_game_pressed", Callable(self, "_on_start_game_pressed"))
	
	if pause_menu:
		# Connect signals
		if pause_menu.has_signal("resume_requested"):
			pause_menu.connect("resume_requested", Callable(self, "_on_resume_requested"))
		if pause_menu.has_signal("main_menu_requested"):
			pause_menu.connect("main_menu_requested", Callable(self, "_on_main_menu_requested"))
		if pause_menu.has_signal("quit_requested"):
			pause_menu.connect("quit_requested", Callable(self, "_on_quit_requested"))
		
		# Make sure it starts hidden
		pause_menu.visible = false
	
	if hud:
		hud.visible = false


func _on_start_game_pressed() -> void:
	if game_manager:
		game_manager.start_game()


func set_player(player_node) -> void:
	player_ref = player_node
	if hud:
		hud.set_player(player_ref)


func show_main_menu() -> void:
	if main_menu:
		main_menu.visible = true


func hide_main_menu() -> void:
	if main_menu:
		main_menu.visible = false


func show_hud() -> void:
	if hud:
		hud.visible = true


func hide_hud() -> void:
	if hud:
		hud.visible = false


func show_pause_menu() -> void:
	if pause_menu:
		pause_menu.visible = true


func hide_pause_menu() -> void:
	if pause_menu:
		pause_menu.visible = false


func show_death_screen() -> void:
	var death_screen = load("res://scenes and scripts/death_screen.tscn").instantiate()
	ui_container.add_child(death_screen)
	death_screen.name = "DeathScreen"


func show_level_completed_screen(completion_time: float, multiplier: float, original_score: int, multiplied_score: int) -> void:
	var level_completed = load("res://scenes and scripts/level_completed_screen.tscn").instantiate()
	ui_container.add_child(level_completed)
	level_completed.name = "LevelCompletedScreen"
	
	if level_completed.has_method("setup"):
		level_completed.setup(completion_time, multiplier, original_score, multiplied_score)
	
	# Connect the continue_pressed signal to level_manager
	var level_manager = get_node_or_null("/root/Main/Managers/LevelManager")
	if level_manager and level_completed.has_signal("continue_pressed"):
		level_completed.connect("continue_pressed", Callable(level_manager, "_on_completion_screen_continue"))


func show_game_completed_screen(final_score: int, total_time: float) -> void:
	var game_completed = load("res://scenes and scripts/game_completed_screen.tscn").instantiate()
	ui_container.add_child(game_completed)
	game_completed.name = "GameCompletedScreen"
	if game_completed.has_method("setup_statistics"):
		game_completed.setup_statistics(final_score, total_time)


func show_transition_animation(animation_name: String) -> void:
	var transition = load("res://scenes and scripts/transition_animation.tscn").instantiate()
	ui_container.add_child(transition)
	transition.name = "TransitionAnimation"
	
	if transition.has_method("set_animation"):
		transition.set_animation(animation_name)
	
	# Connect the animation_completed signal to level_manager
	var level_manager = get_node_or_null("/root/Main/Managers/LevelManager")
	if level_manager and transition.has_signal("animation_completed"):
		transition.connect("animation_completed", Callable(level_manager, "_on_transition_animation_completed"))


func clear_overlay_screens() -> void:
	for child in ui_container.get_children():
		if child != main_menu and child != hud and child != pause_menu:
			child.queue_free()


func hide_all_game_ui() -> void:
	hide_main_menu()
	hide_hud()
	hide_pause_menu()
	clear_overlay_screens()


func show_game_ui() -> void:
	hide_main_menu()
	if hud:
		hud.visible = true
		hud.show_game_ui()


func _on_game_state_changed(old_state, new_state) -> void:
	match new_state:
		state_manager.GameState.MAIN_MENU:
			hide_hud()
			show_main_menu()
			hide_pause_menu()
		state_manager.GameState.PLAYING:
			show_hud()
			hide_main_menu()
			hide_pause_menu()
		state_manager.GameState.PAUSED:
			show_hud()
			hide_main_menu()
			show_pause_menu()


func _on_resume_requested() -> void:
	if game_manager:
		game_manager.resume_game()


func _on_main_menu_requested() -> void:
	if game_manager:
		game_manager.return_to_main_menu()


func _on_quit_requested() -> void:
	if game_manager:
		game_manager.quit_game()
