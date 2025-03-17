extends Node2D

@export var hp : int = 100:
	set = set_hp


func set_hp(new_hp: int):
	hp = clamp(new_hp, 0, 100)
