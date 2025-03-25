extends CharacterBody2D

class_name Player

@export var speed : float = 200.0

@onready var health_point : Node2D = $HP
@onready var gun :  = $Gun


func _ready() -> void:
	z_index = 10
	collision_layer = 2
	collision_mask = 1 | 4 | 8
	
	gun.firing_effect.hide()


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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("fire") and gun.can_shoot():
		gun.shoot()


func handle_hit():
	health_point.hp -= 20
	print("player hit! health: ", health_point.hp)
	
	if health_point.hp <= 0:
		queue_free()
