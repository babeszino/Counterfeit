extends Node

signal enemy_spawned(enemy)
signal all_enemies_cleared

@onready var enemy_container = $"../../EnemyContainer" 
@onready var level_container = $"../../LevelContainer"
@onready var game_manager = $"../GameManager"
@onready var state_manager = $"../GameStateManager"
@onready var weapon_manager = $"../WeaponManager"
@onready var level_manager = $"../LevelManager"

var enemy_scene = preload("res://scenes and scripts/enemy.tscn")
var active_enemies = []
var current_map_sequence = 0


func _ready():
	if game_manager:
		game_manager.connect("game_started", Callable(self, "clear_enemies"))
	
	if level_manager:
		level_manager.connect("map_ready", Callable(self, "_on_map_ready"))


func spawn_enemies() -> void:
	clear_enemies()
	
	
	var level_manager = $"../LevelManager"
	if level_manager:
		current_map_sequence = level_manager.current_map_sequence_position
	
	var current_map = level_container.get_node_or_null("current_map")
	if not current_map:
		return
		
	var spawn_points = current_map.get_node_or_null("SpawnPoints")
	if not spawn_points:
		return
	
	
	for child in spawn_points.get_children():
		if "EnemySpawn" in child.name:
			var enemy = enemy_scene.instantiate()
			enemy_container.add_child(enemy)
			enemy.global_position = child.global_position
			
			if enemy.has_method("equip_weapon"):
				if weapon_manager:
					var weapon = weapon_manager.get_weapon_for_level(current_map_sequence)
					if weapon:
						enemy.equip_weapon(weapon)
			
			if game_manager and game_manager.has_method("register_enemy"):
				game_manager.register_enemy()
			
			active_enemies.append(enemy)
			emit_signal("enemy_spawned", enemy)


func clear_enemies() -> void:
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in all_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	active_enemies.clear()


func _on_enemy_died() -> void:
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	
	if game_manager and game_manager.has_method("on_enemy_died"):
		game_manager.on_enemy_died()
	
	for i in range(active_enemies.size() - 1, -1, -1):
		var enemy = active_enemies[i]
		if !is_instance_valid(enemy):
			active_enemies.remove_at(i)
	
	if active_enemies.size() == 0:
		emit_signal("all_enemies_cleared")


func _on_map_ready(map_instance, sequence_position) -> void:
	current_map_sequence = sequence_position
	
	spawn_enemies_on_map(map_instance)


func spawn_enemies_on_map(map_instance):
	clear_enemies()
	
	
	if not map_instance:
		return
		
	var spawn_points = map_instance.get_node_or_null("SpawnPoints")
	if not spawn_points:
		return
	
	for child in spawn_points.get_children():
		if "EnemySpawn" in child.name:
			var enemy = enemy_scene.instantiate()
			enemy_container.add_child(enemy)
			enemy.global_position = child.global_position
			
			if not enemy.is_connected("enemy_died", Callable(self, "_on_enemy_died")):
				enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
			
			if enemy.has_method("equip_weapon"):
				if weapon_manager:
					var weapon = null
					
					if current_map_sequence == 4:
						weapon = weapon_manager.get_weapon_instance("M4")
					
					else:
						weapon = weapon_manager.get_weapon_for_level(current_map_sequence)
					
					if weapon:
						enemy.equip_weapon(weapon)
			
			if game_manager and game_manager.has_method("register_enemy"):
				game_manager.register_enemy()
			
			active_enemies.append(enemy)
			emit_signal("enemy_spawned", enemy)
