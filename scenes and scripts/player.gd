extends CharacterBody2D

class_name Player

@export var speed : float = 200.0

@onready var health_point : Node2D = $HP
@onready var gun : Gun = $Gun
@onready var player_collision : CollisionShape2D = $CollisionShape2D
@onready var player_animation : AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	player_animation.play("idle")


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("up"):
		direction.y -= 1
	
	if Input.is_action_pressed("down"):
		direction.y += 1
	
	if Input.is_action_pressed("left"):
		direction.x -= 1
	
	if Input.is_action_pressed("right"):
		direction.x += 1
	
	direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	
	update_animation(direction)
	
	if gun and gun.has_method("set_player_moving"):
		gun.set_player_moving(direction != Vector2.ZERO)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("fire") and gun.can_shoot():
		gun.shoot()


func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		player_animation.play("idle")
		
	var facing_direction = (get_global_mouse_position() - global_position).normalized()
	var forward_dot = facing_direction.dot(direction)
	
	var right_vector = Vector2(facing_direction.y, -facing_direction.x)
	var side_dot = right_vector.dot(direction)
	
	if abs(forward_dot) > abs(side_dot):
		player_animation.play("walk")
	else:
		player_animation.play("walk_sideways")


func handle_hit() -> void:
	health_point.hp -= 1
	
	if health_point.hp <= 0:
		var death_scene = load("res://scenes and scripts/death_screen.tscn")
		if death_scene != null:
			var death_screen_instance = death_scene.instantiate()
			if death_screen_instance != null:
				get_tree().root.add_child(death_screen_instance)
		
				get_tree().paused = true
				visible = false
				player_collision.set_deferred("disabled", true)
