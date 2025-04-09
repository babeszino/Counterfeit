extends Node

@onready var weapons_container = $"../../WeaponsContainer"
@onready var game_manager = $"../GameManager"

var weapon_map = {
	0: "BaseballBat",
	1: "Glock18",
	2: "DoubleBarrel",
	3: "M4",
	4: "RocketLauncher"
}


func get_weapon(weapon_name: String) -> Node:
	return weapons_container.get_node_or_null(weapon_name)


func get_weapon_instance(weapon_type: String) -> Node:
	var scene_paths = {
		"BaseballBat": "res://scenes and scripts/baseball_bat.tscn",
		"Glock18": "res://scenes and scripts/glock18.tscn",
		"DoubleBarrel": "res://scenes and scripts/double_barrel_shotgun.tscn",
		"M4": "res://scenes and scripts/m4.tscn",
		"RocketLauncher": "res://scenes and scripts/rocket_launcher.tscn"
	}
	
	if scene_paths.has(weapon_type):
		var weapon_scene = load(scene_paths[weapon_type])
		if weapon_scene:
			return weapon_scene.instantiate()
	
	return null


func get_weapon_for_level(level_index: int) -> Node:
	if level_index == 4:  # rocket launcher time !
		return get_weapon_instance("RocketLauncher")
	
	if weapon_map.has(level_index):
		return get_weapon_instance(weapon_map[level_index])
		
	return get_weapon_instance("BaseballBat")  # fallback, if something goes wrong
