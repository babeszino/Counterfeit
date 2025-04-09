# ################
# lev el controller script - palyabetoltes, atvezetesek, tovabbhaladas
# kezeli a palyakat, a player pozicionalasat es egy palya befejezeset
# ################
extends Node

@onready var game_manager = $Managers/GameManager
@onready var ui_manager = $Managers/UIManager


func _ready() -> void:
	await get_tree().process_frame
	
	if ui_manager:
		ui_manager.show_main_menu()


func show_main_menu() -> void:
	if ui_manager:
		ui_manager.show_main_menu()


func _on_main_menu_start_game_pressed() -> void:
	if game_manager:
		game_manager.start_game()
