# scenes and scripts/maps/finish_door.gd
extends Node2D

@onready var door_animation = $FinishDoor/FinishDoorAnimation
@onready var door_collision = $DoorBody/CollisionShape2D
@onready var door_area = $FinishDoor
@onready var static_body = $DoorBody

var door_is_open : bool = false


func _ready():
	door_is_open = false


func open():
	if door_is_open:
		return
	else:
		door_is_open = true
	
	if door_animation:
		door_animation.play("open")
		await door_animation.animation_finished
	
	door_collision.disabled = true


func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		var level_manager = get_node("/root/Main/Managers/LevelManager")
		if level_manager:
			level_manager.call_deferred("load_next_map")
