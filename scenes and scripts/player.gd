extends CharacterBody2D

class_name Player

@export var speed : float = 200.0

@onready var health_point = $HP
@onready var gun = $Gun
@onready var ammo_display = $CanvasLayer/AmmoDisplay


func _ready() -> void:
	gun.firing_effect.hide()


func _physics_process(delta: float) -> void:
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
	
	position += direction * speed * delta
	
	# look where the cursor is at
	look_at(get_global_mouse_position())
	
	if ammo_display:
		ammo_display.text = gun.get_ammo_display()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("fire") and gun.can_shoot():
		gun.shoot()


func handle_hit():
	health_point.hp -= 20
	print("player hit! health: ", health_point.hp)
	
	#if health_point.hp <= 0:
		#queue_free()
