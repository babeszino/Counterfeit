extends Area2D

@export var speed : int = 450

@onready var despawn_timer = $DespawnTimer
@onready var animation = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var bullet_direction := Vector2.ZERO
var bullet_shooter : Node = null
var shooter_group : String = "player"
var explosion_scene = preload("res://scenes and scripts/explosion.tscn")
var exploded : bool = false


func _ready() -> void:
	despawn_timer.start()
	if animation:
		animation.play("flying")


func _process(delta: float) -> void:
	if bullet_direction != Vector2.ZERO:
		var velocity = bullet_direction * speed * delta
		global_position += velocity


func set_direction(direction: Vector2) -> void:
	bullet_direction = direction
	rotation += direction.angle()
 

func set_shooter(shooter: Node) -> void:
	bullet_shooter = shooter


func _on_despawn_timer_timeout() -> void:
	explode()


func _on_body_entered(body: Node2D) -> void:
	if body == bullet_shooter:
		return
	
	call_deferred("explode")


func explode() -> void:
	if exploded:
		return
	exploded = true
	
	var explosion_instance = explosion_scene.instantiate()
	get_tree().root.add_child(explosion_instance)
	explosion_instance.global_position = global_position
	explosion_instance.shooter_group = shooter_group
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		
	queue_free()
