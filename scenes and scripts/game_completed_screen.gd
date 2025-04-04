extends Control

var main_menu : String = "res://scenes and scripts/main_menu.tscn"
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var final_score_label = $VBoxContainer/FinalScore
@onready var final_time_label = $VBoxContainer/FinalTime


func _ready() -> void:
	main_menu_button.grab_focus()


func setup_statistics(final_score: int, total_time: float) -> void:
	final_score_label.text = "Final score: " + str(final_score)
	final_time_label.text = "Total time: " + format_time(total_time)


func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var remaining_seconds = int(seconds) % 60
	
	if minutes >= 60:
		var hours = minutes / 60
		minutes = minutes % 60
		return str(hours) + ":" + str(minutes).pad_zeros(2) + ":" + str(remaining_seconds).pad_zeros(2)
	else:
		return str(minutes) + ":" + str(remaining_seconds).pad_zeros(2)


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
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.return_to_main_menu()
	
	else:
		get_tree().change_scene_to_file(main_menu)
	
	queue_free()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
