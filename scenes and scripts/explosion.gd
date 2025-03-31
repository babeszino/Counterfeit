extends Area2D

@onready var animation = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var damage_timer = $DamageTimer

var shooter_group : String = "player"
var damaged_targets = []
var damage : int = 70 # default explo damage


func _ready() -> void:
	animation.play("explosion")
	damage_timer.start()
	damage_targets_in_area()


func _on_damage_timer_timeout() -> void:
	damage_targets_in_area()


func damage_targets_in_area() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		var explosion_radius = 200 # just a default value, idk how big this is
		
		if collision_shape and collision_shape.shape is CircleShape2D:
			explosion_radius = collision_shape.shape.radius
		
		if distance <= explosion_radius and not enemy in damaged_targets:
			if enemy.has_method("handle_hit"):
				enemy.handle_hit()
				damaged_targets.append(enemy)
	
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body in damaged_targets:
			continue
		
		if shooter_group == "player" and body.is_in_group("player"):
			continue
		
		if body.has_method("handle_hit"):
			body.handle_hit()
			damaged_targets.append(body)


func _on_animation_finished() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body in damaged_targets:
		return
	
	if shooter_group == "player" and body.is_in_group("player"):
		return
	
	if body.has_method("handle_hit"):
		body.handle_hit(damage)
		damaged_targets.append(body)
