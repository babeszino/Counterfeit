extends CharacterBody2D

@export var hp: int = 100


func handle_hit():
	hp -= 20
	if hp <= 0:
		queue_free()
