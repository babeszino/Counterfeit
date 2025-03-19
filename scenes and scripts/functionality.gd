extends Node2D

enum State { GUARD, ATTACK }

@onready var player_detection_zone = $PlayerDetectionZone

var player : CharacterBody2D = null
var gun = null
var enemy : CharacterBody2D = null

# GUARD state variables
var current_state : int = State.GUARD
var default_position : Vector2 = Vector2.ZERO
var patrol_distance : float = 200.0
var patrol_speed : float = 100.0
var patrol_top_point : Vector2 = Vector2.ZERO
var patrol_bottom_point : Vector2 = Vector2.ZERO
var moving_to_bottom : bool = true


func _ready() -> void:
	await get_tree().process_frame # wait a frame for parent to load
	current_state = State.GUARD


func _physics_process(_delta: float) -> void:
	match current_state:
		State.GUARD:
			if enemy != null:
				var target : Vector2 = Vector2.ZERO
				if moving_to_bottom:
					target = patrol_bottom_point
				else:
					target = patrol_top_point
				
				# Switch direction
				var distance_to_target = enemy.global_position.distance_to(target)
				if distance_to_target < 10.0:
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
	
	if enemy != null:
		default_position = enemy.global_position
		patrol_top_point = default_position
		patrol_bottom_point = default_position + Vector2(0, patrol_distance)
	else:
		printerr("something went wrong, enemy is probably null during initilzation")


func set_state(new_state: int):
	if new_state == current_state:
		return
	
	if new_state == State.GUARD:
		if enemy != null:
			default_position = enemy.global_position
			patrol_top_point = default_position
			patrol_bottom_point = default_position + Vector2(0, patrol_distance)
	
	current_state = new_state


func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		set_state(State.ATTACK)
		player = body
