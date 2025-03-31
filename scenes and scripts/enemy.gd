extends CharacterBody2D

signal enemy_died

@export var movement_speed : float = 50.0

@onready var gun = $Gun
@onready var health_point = $HP
@onready var nav_agent = $NavigationAgent2D
@onready var enemy_ai = $EnemyAI
@onready var enemy_movement = $EnemyMovement
@onready var enemy_animation = $AnimatedSprite2D

var current_animation : String = "idle"
var last_velocity : Vector2 = Vector2.ZERO


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


func handle_hit():
	health_point.hp -= 50
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0 and enemy_ai:
		enemy_ai.player = player_nodes[0]
		enemy_ai.set_state(enemy_ai.State.ATTACK)
		update_path()
	
	if health_point.hp <= 0:
		die()


func die() -> void:
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
	
	var distance_to_player = global_position.distance_to(enemy_ai.player.global_position)
	if distance_to_player > 75.0:
		velocity = direction * movement_speed
		if gun and gun.has_method("set_player_moving"):
			gun.set_player_moving(false)
	else:
		velocity = Vector2.ZERO


func update_path() -> void:
	if enemy_ai and enemy_ai.player:
		nav_agent.target_position = enemy_ai.player.global_position


func update_animation() -> void:
	if velocity.length() < 0.1:
		enemy_animation.play("idle")
	
	var facing_direction = Vector2.RIGHT.rotated(rotation)
	var forward_dot = facing_direction.dot(velocity.normalized())
	
	var right_vector = Vector2(facing_direction.y, -facing_direction.x)
	var side_dot = right_vector.dot(velocity.normalized())
	
	if abs(forward_dot) > abs(side_dot):
		enemy_animation.play("walk")
	else:
		enemy_animation.play("walk_sideways")


func update_weapon_animation() -> void:
	if gun and gun.has_method("set_player_moving"):
		var is_moving = velocity.length() > 10.0
		gun.set_player_moving(is_moving)


func equip_weapon(weapon_scene_path: String) -> void:
	if gun:
		gun.queue_free()
	
	var weapon_scene = load(weapon_scene_path)
	if weapon_scene:
		gun = weapon_scene.instantiate()
		add_child(gun)
	
	if enemy_ai:
		enemy_ai.initialize(self, gun)
	
	
	
