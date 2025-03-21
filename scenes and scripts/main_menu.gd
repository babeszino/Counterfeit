extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton

var main_scene : String = "res://scenes and scripts/main.tscn"


func _ready() -> void:
	start_button.grab_focus()


func _process(_delta: float) -> void:
	if start_button.has_focus():
		start_button.text = ">Start<"
	else:
		start_button.text = "Start"
	
	if quit_button.has_focus():
		quit_button.text = ">Quit<"
	else:
		quit_button.text = "Quit"


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(main_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
