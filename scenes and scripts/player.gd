extends CharacterBody2D

@export var speed : float = 200.0

@onready var health_point = $HP
@onready var gun = $Gun


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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("fire"):
		gun.shoot()


func shoot():
	pass


func handle_hit():
	health_point.hp -= 20
	print("player was hit", health_point.hp)
