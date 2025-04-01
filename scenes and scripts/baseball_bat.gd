extends Node2D

class_name BaseballBat

@onready var attack_cooldown = $AttackCooldown
@onready var player_animation = $PlayerAnimation
@onready var enemy_animation = $EnemyAnimation
@onready var attack_area = $AttackArea
@onready var damage_zone = $AttackArea/DamageZone
@onready var attack_duration = $AttackDuration

# balancing
var player_damage : int = 100
var enemy_damage : int = 10
var player_cooldown : float = 0.33
var enemy_cooldown : float = 1

var weapon_name : String = "Baseball Bat"
var is_attacking : bool = false
var player_moving : bool = false
var current_animation : String = "idle"
var active_animation = null
var is_enemy : bool = false
var hit_targets = []


func _ready() -> void:
	setup_weapon_owner()
	
	if active_animation:
		active_animation.play("idle")
		current_animation = "idle"
	
	damage_zone.disabled = true
	attack_area.monitoring = false


func setup_weapon_owner() -> void:
	var parent = get_parent()
	
	if parent and parent.is_in_group("player"):
		player_animation.visible = true
		enemy_animation.visible = false
		active_animation = player_animation
		is_enemy = false
		attack_area.collision_mask = 4 # 4 - enemies
		attack_cooldown.wait_time = player_cooldown
		
	elif parent and parent.is_in_group("enemy"):
		player_animation.visible = false
		enemy_animation.visible = true
		active_animation = enemy_animation
		is_enemy = true
		attack_area.collision_mask = 2 # 2 - player
		attack_cooldown.wait_time = enemy_cooldown
		
	else:
		player_animation.visible = true
		enemy_animation.visible = false
		active_animation = player_animation
		is_enemy = false


func _physics_process(_delta: float) -> void:
	if is_attacking:
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if not body in hit_targets:
				_handle_hit(body)


func attack() -> bool:
	if !attack_cooldown.is_stopped():
		return false
	
	is_attacking = true
	hit_targets.clear()
	
	damage_zone.disabled = false
	attack_area.monitoring = true
	
	if active_animation and current_animation != "attack":
		active_animation.play("attack")
		current_animation = "attack"
	
	attack_cooldown.start()
	attack_duration.start()
	return true


func _on_attack_duration_timeout() -> void:
	end_attack_state()


func _on_player_animation_animation_finished() -> void:
	if current_animation == "attack" and active_animation == player_animation:
		end_attack_state()


func _on_enemy_animation_animation_finished() -> void:
	if current_animation == "attack" and active_animation == enemy_animation:
		end_attack_state()


func end_attack_state() -> void:
	if is_attacking:
		is_attacking = false
		damage_zone.disabled = true
		attack_area.monitoring = false
		hit_targets.clear()
		update_animation_state()


func can_attack() -> bool:
	return attack_cooldown.is_stopped()


func get_ammo_display() -> String:
	return "MELEE"


func set_player_moving(moving: bool) -> void:
	player_moving = moving
	update_animation_state()


func update_animation_state() -> void:
	if not active_animation:
		return
	
	if is_attacking:
		if current_animation != "attack":
			active_animation.play("attack")
			current_animation = "attack"
	
	elif player_moving:
		if current_animation != "walk":
			active_animation.play("walk")
			current_animation = "walk"
	
	else:
		if current_animation != "idle":
			active_animation.play("idle")
			current_animation = "idle"


func fire_pressed() -> void:
	attack()


func fire_released() -> void:
	pass


func reload() -> void:
	pass


func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_attacking and not body in hit_targets:
		_handle_hit(body)


func _handle_hit(body: Node2D) -> void:
	if !is_attacking:
		return
		
	if body == get_parent():
		return
	
	hit_targets.append(body)
	
	if is_enemy and body.is_in_group("player"):
		if body.has_method("handle_hit"):
			body.handle_hit(enemy_damage)
	elif !is_enemy and body.is_in_group("enemy"):
		if body.has_method("handle_hit"):
			body.handle_hit(player_damage)


func shoot(_target_direction: Vector2 = Vector2.ZERO) -> bool:
	return attack()


func cleanup() -> void:
	if attack_cooldown and attack_cooldown.is_inside_tree():
		attack_cooldown.stop()
	
	if attack_duration and attack_duration.is_inside_tree():
		attack_duration.stop()
	
	is_attacking = false
	player_moving = false
	hit_targets.clear()
	
	if damage_zone:
		damage_zone.disabled = true
	if attack_area:
		attack_area.monitoring = false
	
	if active_animation and active_animation.is_inside_tree():
		active_animation.stop()
