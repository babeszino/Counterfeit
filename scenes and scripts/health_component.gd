extends Node2D

signal health_changed(new_health)
signal health_zero

@export var max_health: int = 100
var current_health: int = max_health

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		emit_signal("health_zero")

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	emit_signal("health_changed", current_health)

func get_health() -> int:
	return current_health

func get_health_percent() -> float:
	return float(current_health) / float(max_health)
