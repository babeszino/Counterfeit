extends CanvasLayer

@onready var new_game_button = $VBoxContainer/NewGameButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready() -> void:
	new_game_button.grab_focus()


func _on_new_game_button_pressed() -> void:
	var game_manager = get_node("/root/Main/Managers/GameManager")
	if game_manager:
		get_tree().paused = false
		game_manager.restart_game()
		queue_free()


func _on_main_menu_button_pressed() -> void:
	var game_manager = get_node("/root/Main/Managers/GameManager")
	if game_manager:
		game_manager.return_to_main_menu()
	queue_free()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
