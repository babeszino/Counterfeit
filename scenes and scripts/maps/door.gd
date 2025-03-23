extends Area2D

signal player_entered

@onready var door_opened = $DoorOpened
@onready var door_closed = $DoorClosed
@onready var door_collision = $CollisionShape2D


func _ready() -> void:
	door_closed.visible = true
	door_opened.visible = false


func open() -> void:
	door_closed.visible = false
	door_opened.visible = true
	door_collision.disabled = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("player_entered")
