extends Node2D

var detection_radius: float = 130.0
var jump_through_distance: float = 50.0
var jump_cooldown: float = 0.5

@onready var wall_jump_ray = $WallJumpRay

var player: CharacterBody2D
var player_animation: AnimatedSprite2D

var can_jump = true
var cooldown_timer = 0.0
var nearest_wall_position = null


func _ready():
	player = get_parent()
	player_animation = player.get_node_or_null("AnimatedSprite2D")


func _physics_process(delta):
	if !can_jump:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_jump = true
	
	find_and_point_to_nearest_wall()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("jump") and can_jump:
		attempt_wall_jump()


func find_and_point_to_nearest_wall():
	var all_tilemaps = []
	find_all_nodes_of_type(player.get_tree().root, "TileMapLayer", all_tilemaps)
	
	var jump_walls_layer = null
	for tilemap in all_tilemaps:
		if "jump" in tilemap.name.to_lower() or "jumpwalls" in tilemap.name.to_lower():
			jump_walls_layer = tilemap
			break
	
	if not jump_walls_layer:
		nearest_wall_position = null
		return
	
	var nearest_distance = detection_radius + 1
	nearest_wall_position = null
	
	var player_cell = jump_walls_layer.local_to_map(jump_walls_layer.to_local(player.global_position))
	var rect_size = Vector2i(10, 10)
	var rect_start = player_cell - rect_size / 2
	
	for x in range(rect_start.x, rect_start.x + rect_size.x):
		for y in range(rect_start.y, rect_start.y + rect_size.y):
			var cell_pos = Vector2i(x, y)
			var tile_id = jump_walls_layer.get_cell_source_id(cell_pos)
			if tile_id != -1:  # meaning there is a tile here
				var wall_pos = jump_walls_layer.to_global(jump_walls_layer.map_to_local(cell_pos))
				var distance = player.global_position.distance_to(wall_pos)
				
				if distance < nearest_distance:
					nearest_distance = distance
					nearest_wall_position = wall_pos
	
	if nearest_wall_position:
		var global_direction = (nearest_wall_position - player.global_position).normalized()
		var local_direction = global_direction.rotated(-global_rotation)
		
		wall_jump_ray.target_position = local_direction * detection_radius
		wall_jump_ray.force_raycast_update()
		
	else:
		wall_jump_ray.target_position = Vector2.ZERO


func attempt_wall_jump():
	wall_jump_ray.force_raycast_update()
	
	if wall_jump_ray.is_colliding() and nearest_wall_position:
		var hit_pos = wall_jump_ray.get_collision_point()
		var hit_distance = player.global_position.distance_to(hit_pos)
		
		if hit_distance <= detection_radius:
			var direction = (hit_pos - player.global_position).normalized()
			
			var space_state = player.get_world_2d().direct_space_state
			var jump_distance = jump_through_distance
			var destination_pos = player.global_position + direction * jump_distance
			
			var obstacle_query = PhysicsRayQueryParameters2D.create(hit_pos + direction * 5.0, destination_pos)
			obstacle_query.collision_mask = 1
			var obstacle_check = space_state.intersect_ray(obstacle_query)
			
			if not obstacle_check:
				player.global_position = destination_pos
				
				can_jump = false
				cooldown_timer = jump_cooldown
				
				if player_animation and player_animation.visible:
					var original_modulate = player_animation.modulate
					player_animation.modulate = Color(1.5, 1.5, 1.5)
					
					var timer = player.get_tree().create_timer(0.1)
					await timer.timeout
					player_animation.modulate = original_modulate


func find_all_nodes_of_type(node, type_name, result_array):
	if node.get_class() == type_name:
		result_array.append(node)
	
	for child in node.get_children():
		find_all_nodes_of_type(child, type_name, result_array)
