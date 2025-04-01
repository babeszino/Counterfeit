extends AnimatedSprite2D

@onready var duration_timer = $DurationTimer
var character_to_follow = null

func _ready():
	play("bleed")
	duration_timer.start()


func _process(delta: float) -> void:
	if character_to_follow and is_instance_valid(character_to_follow):
		global_position = character_to_follow.global_position


func initialize(follow_character, scale_value: Vector2) -> void:
	character_to_follow = follow_character
	scale = scale_value * 5


func _on_duration_timer_timeout() -> void:
	queue_free()
