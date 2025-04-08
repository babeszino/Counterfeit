# ################
# death screen UI, ami a player halalakor jelenik meg
# uj jatek inditasat, a fomenube visszaterest es a kilepes opciokat kezeli
# ################
extends CanvasLayer

# node reference-ek
@onready var new_game_button = $VBoxContainer/NewGameButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitButton


# focus new_game_button-re
func _ready() -> void:
	new_game_button.grab_focus()


# jatek ujrainditasa 
func _on_new_game_button_pressed() -> void:
	var game_manager = get_node("/root/Main/Managers/GameManager")
	if game_manager:
		get_tree().paused = false
		game_manager.restart_game() # unpause ujrainditas elott
		queue_free()


# visszateres a fomenube
func _on_main_menu_button_pressed() -> void:
	var game_manager = get_node("/root/Main/Managers/GameManager")
	if game_manager:
		game_manager.return_to_main_menu()
	queue_free()


# kilepes
func _on_quit_button_pressed() -> void:
	get_tree().quit()
