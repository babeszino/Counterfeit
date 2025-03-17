extends CharacterBody2D

@export var hp : int = 100

@onready var gun = $Gun
@onready var health_point = $HP
@onready var functionality = $Functionality

func _ready() -> void:
	gun.firing_effect.hide()
	functionality.initialize(self, gun)
	


func handle_hit():
	health_point.hp -= 20
	print("enemy hit! health: ", health_point.hp)
	if health_point.hp <= 0:
		queue_free()
