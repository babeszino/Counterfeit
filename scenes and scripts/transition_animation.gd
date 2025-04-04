extends CanvasLayer

signal animation_completed

@onready var animation = $Animation
@onready var animation_timer = $AnimationTimer
@onready var continue_label = $ContinueLabel

var animation_name = "mid_game"
var waiting_for_input = false


func _ready():
	animation.play(animation_name)
	
	animation_timer.start()


func _on_animation_timer_timeout():
	continue_label.visible = true
	waiting_for_input = true


func _input(event):
	if waiting_for_input and event is InputEventKey and event.pressed:
		emit_signal("animation_completed")
		queue_free()
	
	if is_node_ready():
		animation.play(animation_name)


func set_animation(anim_name):
	animation_name = anim_name
