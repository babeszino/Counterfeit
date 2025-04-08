extends CharacterBody2D

signal enemy_died

@export var movement_speed : float = 75.0

@onready var health_point = $HP
@onready var nav_agent = $NavigationAgent2D
@onready var enemy_ai = $EnemyAI
@onready var enemy_movement = $EnemyMovement
@onready var enemy_animation = $AnimatedSprite2D

var bleeding_effect_scene = preload("res://scenes and scripts/bleed_effect.tscn")
var bloodstain_scene = preload("res://scenes and scripts/bloodstain.tscn")

var gun = null
var current_animation : String = "idle"
var last_velocity : Vector2 = Vector2.ZERO
var is_dying : bool = false


func _ready() -> void:
	if enemy_ai:
		enemy_ai.initialize(self, gun)
	
	if enemy_movement:
		enemy_movement.initialize(self)
	
	enemy_animation.play("idle")
	
	enemy_animation.play("idle")
	current_animation = "idle"
	
	call_deferred("actor_setup")


func _physics_process(delta: float) -> void:
	if enemy_ai and enemy_ai.current_state == enemy_ai.State.ATTACK and enemy_ai.player:
		navigate_to_player(delta)
		move_and_slide()
		
		update_weapon_animation()
		update_animation()


func handle_hit(damage_amount: int = 50):
	if is_dying:
		return
	
	health_point.hp -= damage_amount
	spawn_bleeding_effect()
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0 and enemy_ai:
		enemy_ai.player = player_nodes[0]
		enemy_ai.set_state(enemy_ai.State.ATTACK)
		update_path()
	
	if health_point.hp <= 0:
		is_dying = true
		spawn_bloodstain()
		die()


func die() -> void:
	if !is_dying:
		return
	
	remove_from_group("enemy")
	emit_signal("enemy_died")
	queue_free()


func actor_setup() -> void:
	await get_tree().physics_frame
	update_path()


func navigate_to_player(delta: float) -> void:
	if enemy_ai == null or enemy_ai.player == null:
		return
	
	if nav_agent.is_navigation_finished():
		return
	
	update_path()
	
	var next_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_position)
	
	var attack_distance = 75.0
	if gun is BaseballBat:
		attack_distance = 15.0
	
	var distance_to_player = global_position.distance_to(enemy_ai.player.global_position)
	if distance_to_player > attack_distance:
		velocity = direction * movement_speed
		if gun and gun.has_method("set_owner_moving"):
			gun.set_owner_moving(false)
	else:
		velocity = Vector2.ZERO


func update_path() -> void:
	if enemy_ai and enemy_ai.player:
		nav_agent.target_position = enemy_ai.player.global_position


func update_animation() -> void:
	if velocity.length() < 0.1:
		enemy_animation.play("idle")
		return
	
	var facing_direction = Vector2.RIGHT.rotated(rotation)
	var moving_direction = velocity.normalized()
	var angle = abs(facing_direction.angle_to(moving_direction))
	
	if angle < PI/4 or angle > 3*PI/4:
		enemy_animation.play("walk")
	else:
		enemy_animation.play("walk_sideways")


func update_weapon_animation() -> void:
	if gun and gun.has_method("set_owner_moving"):
		var is_moving = velocity.length() > 10.0
		gun.set_owner_moving(is_moving)


func equip_weapon(weapon_scene_path_or_instance) -> void:
	if gun:
		gun.queue_free()
	
	var weapon_instance = null
	
	if weapon_scene_path_or_instance is Node:
		weapon_instance = weapon_scene_path_or_instance
	
	if weapon_instance:
		gun = weapon_instance
		add_child(gun)
	
	if enemy_ai:
		enemy_ai.initialize(self, gun)


func spawn_bleeding_effect() -> void:
	var effect = bleeding_effect_scene.instantiate()
	get_tree().root.add_child(effect)
	effect.global_position = global_position
	effect.initialize(self, scale)


func spawn_bloodstain() -> void:
	var bloodstain = bloodstain_scene.instantiate()
	get_tree().root.add_child(bloodstain)
	bloodstain.global_position = global_position
