extends Node

@onready var game_manager = $Managers/GameManager
@onready var ui_manager = $Managers/UIManager
@onready var state_manager = $Managers/GameStateManager

func _ready() -> void:
	await get_tree().process_frame
	
	if state_manager:
		state_manager.change_state(state_manager.GameState.MAIN_MENU)

func show_main_menu() -> void:
	if ui_manager:
		ui_manager.show_main_menu()


func _on_main_menu_start_game_pressed() -> void:
	if game_manager:
		game_manager.start_game()
