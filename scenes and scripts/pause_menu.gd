extends Control

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton


func _ready() -> void:
	hide()


func _on_visibility_changed() -> void:
	if visible:
		print("Pause menu became visible")
		resume_button.grab_focus()
