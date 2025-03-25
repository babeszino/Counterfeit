extends CharacterBody2D

signal enemy_died

@export var hp : int = 100

@onready var gun = $Gun
@onready var health_point = $HP
@onready var functionality = $Functionality


func _ready() -> void:
	z_index = 5
	
	# spawn_enemies (map_manager.gd) felulirja a collision_layert es a collision_mask-ot valoszinu
	collision_layer = 4
	collision_mask = 1 | 2 | 8
	
	gun.firing_effect.hide()
	functionality.initialize(self, gun)


func handle_hit():
	health_point.hp -= 20
	print("enemy hit! health: ", health_point.hp)
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		functionality.player = player_nodes[0]
		functionality.set_state(functionality.State.ATTACK)
	
	if health_point.hp <= 0:
		queue_free()


func die() -> void:
	emit_signal("enemy_died")
	queue_free()
