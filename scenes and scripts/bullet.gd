extends Area2D

@export var speed : int = 650

@onready var despawn_timer = $DespawnTimer


var direction := Vector2.ZERO


func _ready() -> void:
	despawn_timer.start()


func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed * delta
		
		global_position += velocity


func set_direction(direction: Vector2):
	self.direction = direction
	
	# bullet rotation
	rotation += direction.angle()
 

func _on_despawn_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("handle_hit"):
		body.handle_hit()
		queue_free()
