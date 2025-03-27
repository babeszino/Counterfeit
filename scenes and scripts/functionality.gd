extends Node2D

enum State { GUARD, ATTACK }

@onready var player_detection_zone = $PlayerDetectionZone
@onready var bullet_detection_zone = $BulletDetectionZone
@onready var line_of_sight = $LineOfSightRay

var player : CharacterBody2D = null
var gun = null
var enemy : CharacterBody2D = null
var tracked_player : CharacterBody2D = null

var current_state : int = State.GUARD
var default_position : Vector2 = Vector2.ZERO
var patrol_distance : float = 100.0
var patrol_speed : float = 30.0
var patrol_top_point : Vector2 = Vector2.ZERO
var patrol_bottom_point : Vector2 = Vector2.ZERO
var moving_to_bottom : bool = true
var should_patrol : bool = false
var patrol_timer : float = 0.0


func _ready() -> void:
	await get_tree().process_frame # wait for parent to load
	current_state = State.GUARD
	
	if line_of_sight:
		line_of_sight.enabled = true
	
	patrol_timer = 1.0
	should_patrol = false
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		tracked_player = player_nodes[0]


func _physics_process(delta: float) -> void:
	var player_nodes = get_tree().get_nodes_in_group("player")
	var tracked_player = null
	
	if player_nodes.size() > 0:
		tracked_player = player_nodes[0]
	
	if tracked_player != null and enemy != null:
		var global_direction = (tracked_player.global_position - enemy.global_position).normalized()
		var distance = enemy.global_position.distance_to(tracked_player.global_position)
		
		var local_direction = global_direction.rotated(-enemy.rotation)
		
		line_of_sight.target_position = local_direction * 5000
		line_of_sight.force_raycast_update()
	
	if patrol_timer > 0:
		patrol_timer -= delta
		
		if enemy != null and !should_patrol:
			default_position = enemy.global_position
			patrol_top_point = default_position - Vector2(0, patrol_distance/2)
			patrol_bottom_point = default_position + Vector2(0, patrol_distance/2)
		
		if patrol_timer <= 0:
			should_patrol = true
			
			if enemy != null:
				default_position = enemy.global_position
				patrol_top_point = default_position - Vector2(0, patrol_distance/2)
				patrol_bottom_point = default_position + Vector2(0, patrol_distance/2)
		
		if player != null and current_state == State.ATTACK:
			if has_line_of_sight_to_player():
				gun.shoot()
	
	match current_state:
		State.GUARD:
			if enemy != null:
				if should_patrol:
					var target : Vector2 = Vector2.ZERO
					if moving_to_bottom:
						target = patrol_bottom_point
					else:
						target = patrol_top_point
					
					var distance_to_target = enemy.global_position.distance_to(target)
					
					if distance_to_target < 20.0:
						moving_to_bottom = !moving_to_bottom
					
					var direction = Vector2.ZERO
					if moving_to_bottom:
						direction = Vector2(0, 1)
					else:
						direction = Vector2(0, -1)
					
					if direction != Vector2.ZERO:
						var target_angle = direction.angle() + PI*2
						enemy.rotation = lerp_angle(enemy.rotation, target_angle, 0.1)
					
					enemy.velocity = direction * patrol_speed
					enemy.move_and_slide()
				else:
					enemy.velocity = Vector2.ZERO
			else:
				if enemy != null:
					enemy.velocity = Vector2.ZERO
			
		State.ATTACK:
			if player != null and gun != null:
				var direction = enemy.global_position.direction_to(player.global_position)
				enemy.rotation = lerp_angle(enemy.rotation, direction.angle(), 0.1)
				
				if has_line_of_sight_to_player():
					gun.shoot(direction)
		_:
			printerr("something went very wrong, it should either be GUARD or ATTACK")


func initialize(enemy_node, gun_node):
	self.enemy = enemy_node
	self.gun = gun_node
	
	if line_of_sight:
		line_of_sight.enabled = true
	
	should_patrol = false
	patrol_timer = 2.0
	
	if enemy != null:
		default_position = enemy.global_position
		patrol_top_point = default_position - Vector2(0, patrol_distance/2)
		patrol_bottom_point = default_position + Vector2(0, patrol_distance/2)
		enemy.velocity = Vector2.ZERO


func set_state(new_state: int):
	if new_state == current_state:
		return
	
	if new_state == State.GUARD:
		if enemy != null:
			default_position = enemy.global_position
			patrol_top_point = default_position - Vector2(0, patrol_distance/2)
			patrol_bottom_point = default_position + Vector2(0, patrol_distance/2)
	
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
		else:
			return false
	
	return true


func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var potential_player = body
		
		var global_direction = (potential_player.global_position - enemy.global_position).normalized()
		var distance = enemy.global_position.distance_to(potential_player.global_position)
		
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
