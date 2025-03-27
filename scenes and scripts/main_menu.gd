extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var map_manager = get_node("/root/MapManager")

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
	if map_manager:
		map_manager.start_game()
	
	else:
		print("map_manager var is null")
	
	# hide main menu
	visible = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
