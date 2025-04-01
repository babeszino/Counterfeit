extends AnimatedSprite2D

func _ready() -> void:
	play("bloodstain")


func _on_duration_timer_timeout() -> void:
	stop()
