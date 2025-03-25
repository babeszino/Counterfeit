extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var map_manager = get_node("/root/MapManager")

var current_map = null


func _ready() -> void:
	randomize()
	
	call_deferred("load_next_map")
	
	if player and ui:
		ui.set_player(player)


func get_next_map():
	if map_manager:
		var next_index = (map_manager.current_map_index + 1) % map_manager.maps.size()
		return next_index


func load_next_map():
	if map_manager:
		var next_index = get_next_map()
		map_manager.load_map(next_index)


func spawn_player_at_marker() -> void:
	var player = get_node_or_null("Player")
	var spawn_point = current_map.get_node("SpawnPoints/PlayerSpawn")
	
	player.position = spawn_point.position


func find_enemies(node) -> Array:
	var enemies = []
	
	if node.is_in_group("enemy"):
		enemies.append(node)
	
	for child in node.get_children():
		enemies.append_array(find_enemies(child))
	
	return enemies
