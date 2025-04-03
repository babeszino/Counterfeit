extends CharacterBody2D

class_name Player

@export var speed : float = 200.0

@onready var health_point : Node2D = $HP
@onready var player_collision : CollisionShape2D = $CollisionShape2D
@onready var player_animation : AnimatedSprite2D = $AnimatedSprite2D

var bleeding_effect_scene = preload("res://scenes and scripts/bleed_effect.tscn")
var bloodstain_scene = preload("res://scenes and scripts/bloodstain.tscn")

var gun = null
var current_animation : String = "idle"
var is_dying : bool = false

var knockback_velocity : Vector2 = Vector2.ZERO
var knockback_fadeout : float = 0.8


func _ready() -> void:
	player_animation.play("idle")
	current_animation = "idle"


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
	
	var movement_velocity = direction * speed
	knockback_velocity *= knockback_fadeout
	
	
	velocity = movement_velocity + knockback_velocity
	#velocity = direction * speed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	
	if gun and gun.has_method("set_player_moving"):
		gun.set_player_moving(direction != Vector2.ZERO)
	
	update_animation(direction)


func apply_knockback(knockback_direction: Vector2, force: float) -> void:
	knockback_velocity += knockback_direction * force


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		if gun.has_method("fire_pressed"):
			gun.fire_pressed()
		elif gun.has_method("can_shoot") and gun.can_shoot():
			gun.shoot()
	
	if event.is_action_released("fire") and gun.has_method("fire_released"):
		gun.fire_released()


func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		player_animation.play("idle")
		return
	
	var facing_direction = (get_global_mouse_position() - global_position).normalized()
	var angle = abs(facing_direction.angle_to(direction))
	
	if angle < PI/4 or angle > 3*PI/4:
		player_animation.play("walk")
	else:
		player_animation.play("walk_sideways")


func handle_hit(damage_amount: int = 1) -> void:
	if is_dying:
		return
	
	health_point.hp -= damage_amount
	spawn_bleeding_effect()
	
	if health_point.hp <= 0:
		is_dying = true
		
		spawn_bloodstain()
		
		var death_scene = load("res://scenes and scripts/death_screen.tscn")
		if death_scene != null:
			var death_screen_instance = death_scene.instantiate()
			if death_screen_instance != null:
				get_tree().root.add_child(death_screen_instance)
		
				get_tree().paused = true
				visible = false
				player_collision.set_deferred("disabled", true)


func equip_weapon(weapon_scene_path: String) -> void:
	if gun:
		gun.queue_free()
	
	var weapon_scene = load(weapon_scene_path)
	if weapon_scene:
		gun = weapon_scene.instantiate()
		gun.name = "Gun"
		add_child(gun)


func spawn_bleeding_effect() -> void:
	var effect = bleeding_effect_scene.instantiate()
	get_tree().root.add_child(effect)
	effect.global_position = global_position
	effect.initialize(self, scale)


func spawn_bloodstain() -> void:
	var bloodstain = bloodstain_scene.instantiate()
	get_tree().root.add_child(bloodstain)
	bloodstain.global_position = global_position
