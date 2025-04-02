extends CanvasLayer

signal continue_pressed

@onready var completion_time_label = $Panel/VBoxContainer/CompletionTime
@onready var multiplier_label = $Panel/VBoxContainer/Multiplier
@onready var score_label = $Panel/VBoxContainer/Score
@onready var continue_button = $Panel/VBoxContainer/ContinueButton

var multiplier : float = 1.0


func _ready():
	continue_button.grab_focus()


func setup(completion_time: float, multiplier_value: float, original_score: int, multiplied_score: int):
	multiplier = multiplier_value
	completion_time_label.text = "Time: " + format_time(completion_time)
	multiplier_label.text = "Speed Multiplier: x" + str(multiplier)
	score_label.text = "Score: " + str(multiplied_score)


func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var remaining_seconds = int(seconds) % 60
	return str(minutes) + ":" + str(remaining_seconds).pad_zeros(2)


func _on_continue_button_pressed():
	emit_signal("continue_pressed", multiplier)
	queue_free()
