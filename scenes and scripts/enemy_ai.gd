extends Node2D

enum State { GUARD, ATTACK }

@onready var player_detection_zone = $PlayerDetectionZone
@onready var bullet_detection_zone = $BulletDetectionZone
@onready var line_of_sight = $LineOfSightRay

var player : CharacterBody2D = null
var gun = null
var enemy : CharacterBody2D = null
var current_state : int = State.GUARD


func _ready() -> void:
	await get_tree().process_frame # wait for parent to load
	current_state = State.GUARD
	
	if line_of_sight:
		line_of_sight.enabled = true
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		player = player_nodes[0]


func _physics_process(delta: float) -> void:
	update_line_of_sight()
	process_current_state(delta)


func update_line_of_sight() -> void:
	var player_nodes = get_tree().get_nodes_in_group("player")
	var tracked_player = null
	
	if player_nodes.size() > 0:
		tracked_player = player_nodes[0]
	
	if tracked_player != null and enemy != null and line_of_sight != null:
		var global_direction = (tracked_player.global_position - enemy.global_position).normalized()
		var local_direction = global_direction.rotated(-enemy.rotation)
		
		line_of_sight.target_position = local_direction * 5000
		line_of_sight.force_raycast_update()


func process_current_state(delta: float) -> void:
	match current_state:
		State.GUARD:
			process_guard_state(delta)
			
		State.ATTACK:
			process_attack_state(delta)
			
		_:
			printerr("something went very wrong, it should either be GUARD or ATTACK")


func process_guard_state(delta: float) -> void:
	var enemy_movement = enemy.get_node_or_null("EnemyMovement")
	if enemy_movement:
		enemy_movement.patrol()
	else:
		if enemy:
			enemy.velocity = Vector2.ZERO


func process_attack_state(delta: float) -> void:
	if player != null and gun != null and enemy != null:
		var direction = enemy.global_position.direction_to(player.global_position)
		enemy.rotation = lerp_angle(enemy.rotation, direction.angle(), 0.1)
		
		if has_line_of_sight_to_player():
			gun.shoot(direction)


func initialize(enemy_node, gun_node):
	self.enemy = enemy_node
	self.gun = gun_node
	
	if line_of_sight:
		line_of_sight.enabled = true


func set_state(new_state: int):
	if new_state == current_state:
		return
	
	current_state = new_state
	
	if new_state == State.ATTACK and enemy != null and enemy.has_method("update_path"):
		enemy.update_path()


func has_line_of_sight_to_player() -> bool:
	if player == null or enemy == null or line_of_sight == null:
		return false
	
	var global_direction = (player.global_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(player.global_position)
	
	var local_direction = global_direction.rotated(-enemy.rotation)
	
	line_of_sight.target_position = local_direction * distance
	line_of_sight.force_raycast_update()
	
	if line_of_sight.is_colliding():
		var collider = line_of_sight.get_collider()
		
		if collider == player or collider.is_in_group("player"):
			return true
	
	return true


func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and enemy != null:
		var potential_player = body
		
		var global_direction = (potential_player.global_position - enemy.global_position).normalized()
		var local_direction = global_direction.rotated(-enemy.rotation)
		
		line_of_sight.target_position = local_direction * 5000
		line_of_sight.force_raycast_update()
		
		if line_of_sight.is_colliding():
			var collider = line_of_sight.get_collider()
			if collider == potential_player or collider.is_in_group("player"):
				player = potential_player
				set_state(State.ATTACK)


func _on_bullet_detection_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet") and area.shooter_group == "player":
		var player_nodes = get_tree().get_nodes_in_group("player")
		if player_nodes.size() > 0:
			player = player_nodes[0]
			set_state(State.ATTACK)
