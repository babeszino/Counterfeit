extends CharacterBody2D

class_name Player

@export var speed : float = 200.0

@onready var health_point = $HP
@onready var gun = $Gun
@onready var player_collision = $CollisionShape2D


func _ready() -> void:
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


func handle_hit() -> void:
	health_point.hp -= 20
	
	if health_point.hp <= 0:
		var death_scene = load("res://scenes and scripts/death_screen.tscn")
		if death_scene != null:
			var death_screen_instance = death_scene.instantiate()
			if death_screen_instance != null:
				get_tree().root.add_child(death_screen_instance)
		
				get_tree().paused = true
				visible = false
				player_collision.set_deferred("disabled", true)
