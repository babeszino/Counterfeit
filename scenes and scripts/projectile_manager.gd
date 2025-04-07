extends Node

@onready var projectile_container = $"../../ProjectileContainer"
@onready var game_manager = $"../GameManager"

var bullet_scene = preload("res://scenes and scripts/bullet.tscn")
var rocket_scene = preload("res://scenes and scripts/rocket.tscn")
var explosion_scene = preload("res://scenes and scripts/explosion.tscn")


func spawn_bullet(spawn_position: Vector2, direction: Vector2, shooter: Node) -> Node:
	var bullet = bullet_scene.instantiate()
	projectile_container.add_child(bullet)
	bullet.global_position = spawn_position
	bullet.set_direction(direction)
	bullet.set_shooter(shooter)
	return bullet


func spawn_rocket(spawn_position: Vector2, direction: Vector2, shooter: Node) -> Node:
	var rocket = rocket_scene.instantiate()
	projectile_container.add_child(rocket)
	rocket.global_position = spawn_position
	rocket.set_direction(direction)
	rocket.set_shooter(shooter)
	return rocket


func spawn_explosion(position: Vector2, shooter_group: String = "player", damage: int = 70) -> Node:
	var explosion = explosion_scene.instantiate()
	projectile_container.add_child(explosion)
	explosion.global_position = position
	explosion.shooter_group = shooter_group
	explosion.damage = damage
	return explosion


func clear_projectiles():
	for child in projectile_container.get_children():
		child.queue_free()
