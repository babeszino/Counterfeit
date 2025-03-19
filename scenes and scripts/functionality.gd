extends Node2D

enum State {
	GUARD, 
	ATTACK
}

@onready var player_detection_zone = $PlayerDetectionZone
@onready var guard_timer = $GuardTimer

var current_state : int = State.GUARD: set = set_state
var player : Player = null
var gun : Gun = null
var enemy : CharacterBody2D = null

# GUARD state variables
var default_position : Vector2 = Vector2.ZERO
var guard_location : Vector2 = Vector2.ZERO
var guard_location_reached : bool = false
var enemy_velocity : Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	match current_state:
		State.GUARD:
			if !guard_location_reached:
				enemy.velocity = enemy_velocity
				enemy.move_and_slide()
				if enemy.global_position.distance_to(guard_location) < 5:
					guard_location_reached = true
					enemy.velocity = Vector2.ZERO
					guard_timer.start()
			
		State.ATTACK:
			if player != null and gun != null:
				# .angle() because rotation is a float and this way we get the angle
				# float lerp_angle(from: float, to: float, weight: float) -> smoother enemy turn
				enemy.rotation = lerp_angle(enemy.rotation, enemy.global_position.direction_to(player.global_position).angle(), 0.1)
				var direction_to_shoot = enemy.global_position.direction_to(player.global_position)
				gun.shoot(direction_to_shoot)
			else:
				printerr("something went wrong, there is no player or gun")
		_:
			printerr("something went very wrong, it should either be SCOUT or ATTACK")


func initialize(enemy, gun: Gun):
	self.enemy = enemy
	self.gun = gun


func set_state(new_state: int):
	if new_state == current_state:
		return
	
	if new_state == State.GUARD:
		default_position = enemy.global_position
		guard_timer.start()
		guard_location_reached = true
	
	current_state = new_state


func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_state(State.ATTACK)
		player = body


func _on_guard_timer_timeout() -> void:
	var guard_range = 50
	var random_x = randf_range(-guard_range, guard_range)
	var random_y = randf_range(-guard_range, guard_range)
	
	guard_location = Vector2(random_x, random_y) + default_position
	guard_location_reached = false
	enemy_velocity = enemy.global_position.direction_to(guard_location)
