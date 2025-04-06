extends Node

@onready var game_manager = $Managers/GameManager
@onready var ui_container = $UIContainer

func _ready() -> void:
	call_deferred("show_main_menu")


func show_main_menu() -> void:
	var main_menu = load("res://scenes and scripts/main_menu.tscn").instantiate()
	add_child(main_menu)
	main_menu.connect("start_game_pressed", Callable(self, "_on_start_game_pressed"))


func _on_start_game_pressed() -> void:
	if game_manager:
		game_manager.start_game()
