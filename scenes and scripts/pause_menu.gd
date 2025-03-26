extends CanvasLayer

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton


func _ready() -> void:
	hide()
	resume_button.pressed.connect(resume_game)
	quit_button.pressed.connect(quit_game)


func resume_game() -> void:
	get_tree().paused = false
	hide()


func quit_game() -> void:
	get_tree().quit()


func show_pause_menu() -> void:
	show()
	get_tree().paused = true
