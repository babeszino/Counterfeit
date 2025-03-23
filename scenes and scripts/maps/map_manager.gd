extends Node

# Store the map scene paths for easy loading
var maps = [
	"res://scenes and scripts/maps/map_layout_1.tscn",
	"res://scenes and scripts/maps/map_layout_2.tscn"
	# You can uncomment these when you create the additional maps
	# "res://scenes and scripts/maps/map_layout_3.tscn",
	# "res://scenes and scripts/maps/map_layout_4.tscn",
	# "res://scenes and scripts/maps/map_layout_5.tscn"
]

# Store the randomized map order
var map_order = []
var current_map_index = 0

# Signal to notify when all maps are completed
signal all_maps_completed

func _ready():
	randomize() # Initialize random number generator
	shuffle_maps()

# Shuffle the maps into a random order
func shuffle_maps():
	map_order = maps.duplicate()
	map_order.shuffle()
	current_map_index = 0
	print("Map order: ", map_order)

# Get the next map in sequence, or null if we're done
func get_next_map():
	if current_map_index >= map_order.size():
		emit_signal("all_maps_completed")
		return null
	
	var next_map = map_order[current_map_index]
	current_map_index += 1
	
	var file = FileAccess.open(next_map, FileAccess.READ)
	if file:
		file.close()
		return next_map
	
	else:
		print("WARNING: Map file doesn't exist: ", next_map)
		if current_map_index < map_order.size():
			# Try the next map
			return get_next_map()
		
		else:
			emit_signal("all_maps_completed")
			return null


func reset():
	shuffle_maps()


func is_final_map():
	return current_map_index == map_order.size() - 1
