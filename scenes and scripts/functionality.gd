extends Node2D

enum State { GUARD, ATTACK }

@onready var player_detection_zone = $PlayerDetectionZone

var player : CharacterBody2D = null
var gun = null
var enemy : CharacterBody2D = null

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
	
	patrol_timer = 1.0
	should_patrol = false


func _physics_process(delta: float) -> void:
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
					
					# enemy faces the direction it is going
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
				# rotate in direction of player
				enemy.rotation = lerp_angle(enemy.rotation, enemy.global_position.direction_to(player.global_position).angle(), 0.1)
				
				# shoot at player
				var direction_to_shoot = enemy.global_position.direction_to(player.global_position)
				gun.shoot(direction_to_shoot)
			else:
				printerr("something went wrong, there is no player or gun")
		_:
			printerr("something went very wrong, it should either be GUARD or ATTACK")


func initialize(enemy_node, gun_node):
	self.enemy = enemy_node
	self.gun = gun_node
	
	should_patrol = false
	patrol_timer = 2.0
	
	if enemy != null:
		default_position = enemy.global_position
		patrol_top_point = default_position - Vector2(0, patrol_distance/2)
		patrol_bottom_point = default_position + Vector2(0, patrol_distance/2)
		enemy.velocity = Vector2.ZERO
	
	else:
		printerr("something went wrong, enemy is probably null during initilzation")


func set_state(new_state: int):
	if new_state == current_state:
		return
	
	if new_state == State.GUARD:
		if enemy != null:
			default_position = enemy.global_position
			patrol_top_point = default_position - Vector2(0, patrol_distance/2)
			patrol_bottom_point = default_position + Vector2(0, patrol_distance/2)
	
	current_state = new_state


func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		set_state(State.ATTACK)
		player = body
