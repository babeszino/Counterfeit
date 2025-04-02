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
var damage : int = 50
var explosive_damage : int = 70


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
	
	var weapon = null
	if shooter.has_node("Gun"):
		weapon = shooter.get_node("Gun")
	
	if weapon:
		if weapon.has_method("get_damage"):
			damage = weapon.get_damage()
		if weapon.has_method("get_explosive_damage"):
			explosive_damage = weapon.get_explosive_damage()


func _on_despawn_timer_timeout() -> void:
	explode()


func _on_body_entered(body: Node2D) -> void:
	if body == bullet_shooter:
		return
	
	if body.has_method("handle_hit") and body != bullet_shooter:
		body.handle_hit(damage)
	
	call_deferred("explode")


func explode() -> void:
	if exploded:
		return
	exploded = true
	
	var explosion_instance = explosion_scene.instantiate()
	get_tree().root.add_child(explosion_instance)
	explosion_instance.global_position = global_position
	explosion_instance.shooter_group = shooter_group
	explosion_instance.damage = explosive_damage
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		
	queue_free()
