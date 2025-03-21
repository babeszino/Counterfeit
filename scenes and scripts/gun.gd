extends Node2D

class_name Gun

@export var Bullet : PackedScene

@onready var end_of_gun = $EndOfGun
@onready var attack_cooldown = $AttackCooldown
@onready var firing_effect = $FiringEffect
@onready var firing_animation = $FiringAnimation
@onready var reload_timer = $ReloadTimer

var max_ammo : int = 18
var current_ammo : int = 18
var is_reloading : bool = false


func _ready() -> void:
	current_ammo = max_ammo


func _process(_delta: float) -> void:
	if current_ammo <= 0 and !is_reloading:
		reload()
	
	if Input.is_action_just_pressed("reload") and !is_reloading and current_ammo < max_ammo:
		reload()


func shoot(target_direction: Vector2 = Vector2.ZERO) -> bool:
	if current_ammo <= 0:
		reload()
		return false
	
	if is_reloading:
		return false
	
	if !attack_cooldown.is_stopped():
		return false
	
	var bullet_instance = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet_instance)

	bullet_instance.global_position = end_of_gun.global_position
	
	if target_direction == Vector2.ZERO:
		var mouse_direction = (get_global_mouse_position() - global_position).normalized()
		var gun_forward = Vector2.RIGHT.rotated(global_rotation)
		var angle_diff = abs(gun_forward.angle_to(mouse_direction))
		
		if angle_diff > PI/2:
			target_direction = gun_forward
		else:
			target_direction = mouse_direction
	
	bullet_instance.set_direction(target_direction)
	
	current_ammo -= 1
	
	attack_cooldown.start()
	firing_animation.play("FiringAnimation")
	
	if current_ammo <= 0:
		reload()
	
	return true


func reload() -> void:
	if !is_reloading and current_ammo < max_ammo:
		is_reloading = true
		print("Reloading...")
		reload_timer.start()


func can_shoot() -> bool:
	return attack_cooldown.is_stopped() and current_ammo > 0 and !is_reloading


func _on_reload_timer_timeout() -> void:
	current_ammo = max_ammo
	is_reloading = false
	print("Reload complete. Ammo: ", current_ammo)


func get_ammo_display() -> String:
	return str(current_ammo) + " / " + str(max_ammo)
