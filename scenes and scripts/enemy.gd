extends CharacterBody2D

signal enemy_died

@export var movement_speed : float = 50.0

@onready var gun = $Gun
@onready var health_point = $HP
@onready var nav_agent = $NavigationAgent2D
@onready var enemy_ai = $EnemyAI
@onready var enemy_movement = $EnemyMovement


func _ready() -> void:
	gun.firing_effect.hide()
	
	if enemy_ai:
		enemy_ai.initialize(self, gun)
	
	if enemy_movement:
		enemy_movement.initialize(self)
	
	# ezek valoszinu az inspector tab-on is editelhetok es onnan is mukodnek, majd tesztelni
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
	call_deferred("actor_setup")


func _physics_process(delta: float) -> void:
	if enemy_ai and enemy_ai.current_state == enemy_ai.State.ATTACK and enemy_ai.player:
		navigate_to_player(delta)
		move_and_slide()


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
	else:
		velocity = Vector2.ZERO


func update_path() -> void:
	if enemy_ai and enemy_ai.player:
		nav_agent.target_position = enemy_ai.player.global_position
