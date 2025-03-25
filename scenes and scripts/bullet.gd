extends Area2D

@export var speed : int = 650

@onready var despawn_timer = $DespawnTimer

var bullet_direction := Vector2.ZERO
var bullet_shooter : Node = null
var shooter_group : String = ""


func _ready() -> void:
	despawn_timer.start()
	
	collision_layer = 8
	collision_mask = 1 | 2 | 4


func _process(delta: float) -> void:
	if bullet_direction != Vector2.ZERO:
		var velocity = bullet_direction * speed * delta
		
		global_position += velocity


func set_direction(direction: Vector2) -> void:
	bullet_direction = direction
	rotation += direction.angle()
 

func set_shooter(shooter: Node) -> void:
	bullet_shooter = shooter
	
	if shooter.is_in_group("player"):
		shooter_group = "player"
		collision_mask = 1 | 4
	elif shooter.is_in_group("enemy"):
		shooter_group = "enemy"
		collision_mask = 1 | 2


func _on_despawn_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
		return
	
	if body == bullet_shooter:
		return
	
	if body.has_method("handle_hit"):
		body.handle_hit()
		queue_free()
