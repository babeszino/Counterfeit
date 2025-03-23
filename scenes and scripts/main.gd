extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var map_manager = get_node("/root/MapManager")

var current_map = null
var door_scene = preload("res://scenes and scripts/maps/door.tscn")
var door_instance = null


func _ready() -> void:
	randomize()
	
	call_deferred("load_next_map")
	
	if player and ui:
		ui.set_player(player)


func get_next_map():
	if map_manager:
		var next_index = (map_manager.current_map_index + 1) % map_manager.maps.size()
		return next_index
	
	else:
		print("ERROR: MapManager not found")
		return 0


func load_next_map():
	if map_manager:
		var next_index = get_next_map()
		map_manager.load_map(next_index)
	else:
		print("ERROR: MapManager not found")


func spawn_player_at_marker() -> void:
	var player = get_node_or_null("Player")
	var spawn_point = null
	
	# elso if nem tudom, hogy kell e -> majd tesztelni
	if current_map.has_node("SpawnPoint"):
		spawn_point = current_map.get_node("SpawnPoint")
	elif current_map.has_node("PlayerSpawn"):
		spawn_point = current_map.get_node("PlayerSpawn")
	
	if player and spawn_point:
		print("Moving player to spawn point: ", spawn_point)
		player.position = spawn_point.position


func connect_enemy_signals() -> void:
	var enemies = find_enemies(current_map)
	print("Found ", enemies.size(), " enemies")
	
	for enemy in enemies:
		if enemy.has_signal("enemy_died"):
			if not enemy.is_connected("enemy_died", _on_enemy_died):
				enemy.connect("enemy_died", _on_enemy_died)


func setup_door() -> void:
	door_instance = door_scene.instantiate()
	
	var door_marker = null
	if current_map.has_node("DoorPosition"):
		door_marker = current_map.get_node("DoorPosition")
	
	door_instance.position = door_marker.position
	
	add_child(door_instance)
	
	if door_instance.has_signal("door_entered"):
		if not door_instance.is_connected("door_entered", _on_door_entered):
			door_instance.connect("door_entered", _on_door_entered)


func find_enemies(node) -> Array:
	var enemies = []
	
	if node.is_in_group("enemy"):
		enemies.append(node)
	
	for child in node.get_children():
		enemies.append_array(find_enemies(child))
	
	return enemies


func _on_enemy_died() -> void:
	var remaining_enemies = find_enemies(current_map)
	print("Remaining enemies: ", remaining_enemies.size())
	
	if remaining_enemies.size() <= 1:
		if door_instance:
			door_instance.call_deferred("open")


func _on_door_entered() -> void:
	print("Door entered! Loading next map...")
	call_deferred("load_next_map")
