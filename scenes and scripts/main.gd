extends Node2D

@onready var player = $Player
@onready var ui = $UI


func _ready() -> void:
	# change the random number seed every time
	randomize()
	
	if player and ui:
		ui.set_player(player)
