extends Node

@onready var ui_container = $"../../UIContainer"
@onready var hud = ui_container.get_node_or_null("HUD/UI")
@onready var main_menu = ui_container.get_node_or_null("Menus/MainMenu")
@onready var pause_menu = ui_container.get_node_or_null("Menus/PauseMenu")
@onready var death_screen = ui_container.get_node_or_null("Overlays/DeathScreen")
@onready var level_completed_screen = ui_container.get_node_or_null("Overlays/LevelCompletedScreen")
@onready var game_completed_screen = ui_container.get_node_or_null("Overlays/GameCompletedScreen")
@onready var transition_animation = ui_container.get_node_or_null("Overlays/TransitionAnimation")

@onready var game_manager = $"../GameManager"
@onready var state_manager = $"../GameStateManager"

var player_ref = null

func _ready() -> void:
	if pause_menu:
		if not pause_menu.is_connected("resume_requested", Callable(self, "_on_resume_requested")):
			pause_menu.connect("resume_requested", Callable(self, "_on_resume_requested"))
		if not pause_menu.is_connected("main_menu_requested", Callable(self, "_on_main_menu_requested")):
			pause_menu.connect("main_menu_requested", Callable(self, "_on_main_menu_requested"))
		if not pause_menu.is_connected("quit_requested", Callable(self, "_on_quit_requested")):
			pause_menu.connect("quit_requested", Callable(self, "_on_quit_requested"))
	
	if state_manager:
		if not state_manager.is_connected("state_changed", Callable(self, "_on_game_state_changed")):
			state_manager.connect("state_changed", Callable(self, "_on_game_state_changed"))
	
	hide_all_game_ui()
	show_main_menu()


func set_player(player_node) -> void:
	player_ref = player_node
	
	if hud:
		hud.set_player(player_ref)


func show_hud() -> void:
	if hud:
		hud.visible = true
		hud.show_game_ui()


func hide_hud() -> void:
	if hud:
		hud.visible = false
		hud.hide_game_ui()


func show_main_menu() -> void:
	if main_menu:
		main_menu.visible = true


func hide_main_menu() -> void:
	if main_menu:
		main_menu.visible = false


func show_pause_menu() -> void:
	if pause_menu:
		pause_menu.visible = true


func hide_pause_menu() -> void:
	if pause_menu:
		pause_menu.visible = false


func show_death_screen() -> void:
	if death_screen:
		death_screen.visible = true


func hide_death_screen() -> void:
	if death_screen:
		death_screen.visible = false


func show_level_completed_screen(completion_time: float, multiplier: float, original_score: int, multiplied_score: int) -> void:
	if level_completed_screen:
		level_completed_screen.visible = true
		if level_completed_screen.has_method("setup"):
			level_completed_screen.setup(completion_time, multiplier, original_score, multiplied_score)


func show_game_completed_screen(final_score: int, total_time: float) -> void:
	if game_completed_screen:
		game_completed_screen.visible = true
		if game_completed_screen.has_method("setup_statistics"):
			game_completed_screen.setup_statistics(final_score, total_time)


func show_transition_animation(animation_name: String) -> void:
	if transition_animation:
		transition_animation.visible = true
		if transition_animation.has_method("set_animation"):
			transition_animation.set_animation(animation_name)


func hide_all_game_ui() -> void:
	hide_hud()
	hide_main_menu()
	hide_pause_menu()
	hide_death_screen()
	if level_completed_screen:
		level_completed_screen.visible = false
	if game_completed_screen:
		game_completed_screen.visible = false
	if transition_animation:
		transition_animation.visible = false


func show_game_ui() -> void:
	show_hud()
	hide_main_menu()
	hide_pause_menu()


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


func _on_pause_menu_resume_requested() -> void:
	if game_manager:
		game_manager.resume_game()


func _on_pause_menu_main_menu_requested() -> void:
	if game_manager:
		game_manager.return_to_main_menu()


func _on_pause_menu_quit_requested() -> void:
	if game_manager:
		game_manager.quit_game()
