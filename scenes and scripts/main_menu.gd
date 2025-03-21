extends Control

@onready var start_button = $VBoxContainer/StartButton
var main_scene : String = "res://scenes and scripts/main.tscn"


func _ready() -> void:
	start_button.grab_focus()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(main_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
