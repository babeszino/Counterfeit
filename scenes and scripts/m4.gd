extends Node2D

class_name M4

signal reload_started

@onready var end_of_gun = $EndOfGun
@onready var attack_cooldown = $AttackCooldown
@onready var reload_timer = $ReloadTimer
@onready var player_animation = $PlayerAnimation
@onready var enemy_animation = $EnemyAnimation

# balancing
var player_damage : int = 35
var enemy_damage : int = 5
var player_cooldown : float = 0.08
var enemy_cooldown : float = 0.8

var bullet_scene
var max_ammo : int = 30
var current_ammo : int = 30
var is_reloading : bool = false
var weapon_name : String = "M4 Assault Rifle"
var auto_fire : bool = true

var current_animation : String = "idle"
var is_shooting : bool = false
var player_moving : bool = false
var active_animation = null
var is_enemy : bool = false
var fire_button_held : bool = false


func _ready() -> void:
	current_ammo = max_ammo
	bullet_scene = load("res://scenes and scripts/bullet.tscn")
	
	setup_weapon_owner()
	
	if active_animation:
		active_animation.play("idle")
		current_animation = "idle"


func setup_weapon_owner() -> void:
	var parent = get_parent()
	
	if parent and parent.is_in_group("player"):
		player_animation.visible = true
		enemy_animation.visible = false
		active_animation = player_animation
		is_enemy = false
		attack_cooldown.wait_time = player_cooldown
	
	elif parent and parent.is_in_group("enemy"):
		player_animation.visible = false
		enemy_animation.visible = true
		active_animation = enemy_animation
		is_enemy = true
		attack_cooldown.wait_time = enemy_cooldown
	
	else:
		player_animation.visible = true
		enemy_animation.visible = false
		active_animation = player_animation
		is_enemy = false


func _process(_delta: float) -> void:
	if current_ammo <= 0 and !is_reloading:
		reload()
	
	if Input.is_action_just_pressed("reload") and !is_reloading and current_ammo < max_ammo:
		reload()
	
	if !is_enemy and auto_fire and fire_button_held and can_shoot():
		shoot()
	
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
	
	var bullet_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = end_of_gun.global_position
	
	bullet_instance.set_shooter(get_parent())
	
	if target_direction == Vector2.ZERO:
		var mouse_direction = (get_global_mouse_position() - global_position).normalized()
		var gun_forward = Vector2.RIGHT.rotated(global_rotation)
		var angle_diff = abs(gun_forward.angle_to(mouse_direction))
		
		if angle_diff > PI/2:
			target_direction = gun_forward
		else:
			target_direction = mouse_direction
		
	# weapon spread
	if auto_fire:
		var spread = 0.08
		target_direction = target_direction.rotated(randf_range(-spread, spread))
	
	bullet_instance.set_direction(target_direction)
	
	current_ammo -= 1
	
	attack_cooldown.start()
	
	is_shooting = true
	if active_animation and current_animation != "shoot":
		active_animation.play("shoot")
		current_animation = "shoot"
	
	if current_ammo <= 0:
		reload()
	
	return true


func reload() -> void:
	if !is_reloading and current_ammo < max_ammo:
		is_reloading = true
		reload_timer.start()
		emit_signal("reload_started", reload_timer.wait_time)


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
	if not active_animation:
		return
		
	if is_shooting:
		if current_animation != "shoot":
			active_animation.play("shoot")
			current_animation = "shoot"
	
	elif player_moving:
		if current_animation != "walk":
			active_animation.play("walk")
			current_animation = "walk"
	
	else:
		if current_animation != "idle":
			active_animation.play("idle")
			current_animation = "idle"


func fire_pressed() -> void:
	fire_button_held = true
	shoot()


func fire_released() -> void:
	fire_button_held = false


func get_damage() -> int:
	var parent = get_parent()
	if parent and parent.is_in_group("player"):
		return player_damage
	
	elif parent and parent.is_in_group("enemy"):
		return enemy_damage
	
	else:
		return player_damage
