extends Control

var main_menu : String = "res://scenes and scripts/main_menu.tscn"
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitButton


func _ready() -> void:
	main_menu_button.grab_focus()


func _process(_delta: float) -> void:
	if main_menu_button.has_focus():
		main_menu_button.text = ">Main Menu<"
	else:
		main_menu_button.text = "Main Menu"
	
	if quit_button.has_focus():
		quit_button.text = ">Quit<"
	else:
		quit_button.text = "Quit"


func _on_main_menu_button_pressed() -> void:
	var main_scene = get_tree().root.get_node_or_null("Main")
	if main_scene and main_scene.has_method("show_main_menu"):
		main_scene.show_main_menu()
	
	else:
		get_tree().change_scene_to_file(main_menu)
	
	queue_free()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
