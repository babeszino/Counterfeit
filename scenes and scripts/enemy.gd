extends CharacterBody2D

@export var hp : int = 100

@onready var gun = $Gun
@onready var health_point = $HP


func _ready() -> void:
	gun.firing_effect.hide()


func handle_hit():
	health_point.hp -= 20
	print("enemy hit! health: ", health_point.hp)
	if health_point.hp <= 0:
		queue_free()
