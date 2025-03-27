extends Node2D

@onready var door_animation = $FinishDoor/FinishDoorAnimation
@onready var door_collision = $DoorBody/CollisionShape2D
@onready var door_area = $FinishDoor
@onready var static_body = $DoorBody

var door_is_open : bool = false


func _ready():
	door_is_open = false


func _process(_delta):
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0 and not door_is_open:
		open()


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
		var map_manager = get_tree().root.get_node_or_null("MapManager")
		if map_manager:
			map_manager.load_next_map()
