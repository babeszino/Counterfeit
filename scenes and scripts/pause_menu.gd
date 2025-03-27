extends Control

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton

signal resume_requested
signal main_menu_requested
signal quit_requested


func _ready() -> void:
	hide()


func _on_visibility_changed() -> void:
	if visible:
		print("Pause menu became visible")
		resume_button.grab_focus()


func _on_resume_button_pressed() -> void:
	emit_signal("resume_requested")


func _on_main_menu_button_pressed() -> void:
	emit_signal("main_menu_requested")


func _on_quit_button_pressed() -> void:
	emit_signal("quit_requested")
