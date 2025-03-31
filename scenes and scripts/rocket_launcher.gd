extends Node2D

class_name RocketLauncher

@onready var end_of_gun = $EndOfGun
@onready var attack_cooldown = $AttackCooldown
@onready var firing_animation = $FiringAnimation
@onready var reload_timer = $ReloadTimer
@onready var player_animation = $PlayerAnimation

var player_damage : int = 50
var player_explosive_damage : int = 70

var rocket_scene
var max_ammo : int = 2
var current_ammo : int = 2
var is_reloading : bool = false
var weapon_name : String = "Rocket Launcher"
var auto_fire : bool = false

var current_animation : String = "idle"
var is_shooting : bool = false
var player_moving : bool = false


func _ready() -> void:
	current_ammo = max_ammo
	rocket_scene = load("res://scenes and scripts/rocket.tscn")
	
	player_animation.play("idle")
	current_animation = "idle"


func _process(_delta: float) -> void:
	if current_ammo <= 0 and !is_reloading:
		reload()
	
	if Input.is_action_just_pressed("reload") and !is_reloading and current_ammo < max_ammo:
		reload()
	
	if is_shooting and attack_cooldown.is_stopped():
		is_shooting = false
		update_animation_state()


func shoot(target_direction: Vector2 = Vector2.ZERO) -> bool:
	if current_ammo <= 0:
		reload()
		return false
	
	if is_reloading:
		return false
	
	if !attack_cooldown.is_stopped():
		return false
	
	var rocket_instance = rocket_scene.instantiate()
	get_tree().root.add_child(rocket_instance)
	rocket_instance.global_position = end_of_gun.global_position
	
	rocket_instance.set_shooter(get_parent())
	
	if target_direction == Vector2.ZERO:
		var mouse_direction = (get_global_mouse_position() - global_position).normalized()
		var gun_forward = Vector2.RIGHT.rotated(global_rotation)
		var angle_diff = abs(gun_forward.angle_to(mouse_direction))
		
		if angle_diff > PI/2:
			target_direction = gun_forward
		else:
			target_direction = mouse_direction
	
	rocket_instance.set_direction(target_direction)
	
	current_ammo -= 1
	
	attack_cooldown.start()
	firing_animation.play("FiringAnimation")
	
	is_shooting = true
	if current_animation != "shoot":
		player_animation.play("shoot")
		current_animation = "shoot"
	
	if current_ammo <= 0:
		reload()
	
	return true


func reload() -> void:
	if !is_reloading and current_ammo < max_ammo:
		is_reloading = true
		reload_timer.start()


func can_shoot() -> bool:
	return attack_cooldown.is_stopped() and current_ammo > 0 and !is_reloading


func _on_reload_timer_timeout() -> void:
	current_ammo = max_ammo
	is_reloading = false
	update_animation_state()


func get_ammo_display() -> String:
	return str(current_ammo) + " / " + str(max_ammo)


func set_player_moving(moving: bool) -> void:
	player_moving = moving
	update_animation_state()


func update_animation_state() -> void:
	if is_shooting:
		if current_animation != "shoot":
			player_animation.play("shoot")
			current_animation = "shoot"
	
	elif player_moving:
		if current_animation != "walk":
			player_animation.play("walk")
			current_animation = "walk"
	
	else:
		if current_animation != "idle":
			player_animation.play("idle")
			current_animation = "idle"


func fire_pressed() -> void:
	shoot()


func fire_released() -> void:
	pass


func get_damage() -> int:
	return player_damage


func get_explosive_damage() -> int:
	return player_explosive_damage
