extends Node2D

enum State {
	SCOUT, 
	ATTACK
}

@onready var player_detection_zone = $PlayerDetectionZone

var current_state : int = State.SCOUT: set = set_state
var player: Player = null
var gun: Gun = null
var enemy = null


func _process(delta: float) -> void:
	match current_state:
		State.SCOUT:
			pass
		State.ATTACK:
			if player != null and gun != null:
				# .angle() at the end because rotation is a float and this way we get the angle
				enemy.rotation = enemy.global_position.direction_to(player.global_position).angle()
				
		
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
	
	current_state = new_state


func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_state(State.ATTACK)
		player = body
