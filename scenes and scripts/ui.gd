extends CanvasLayer

@onready var health_display : Control = $TopContainer/HealthDisplay
@onready var ammo_display : Label = $BottomContainer/AmmoDisplay
@onready var pause_menu : Control = $PauseMenu

var player = null


func _ready() -> void:
	health_display.hide_all_health_bars()
	
	# connect to player (if it already exists)
	find_player()


func _process(_delta: float) -> void:
	if player == null:
		find_player()
	
	if is_instance_valid(player):
		# display hp
		if player.health_point != null:
			update_health_bar(player.health_point.hp)
		else:
			health_display.hide_all_health_bars()
		
		# display ammo
		var gun = player.get_node("Gun")
		update_ammo_display(gun.get_ammo_display())
	else:
		health_display.hide_all_health_bars()


func find_player() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		set_player(node)
		return


func set_player(player_node) -> void:
	player = player_node


func update_health_bar(health: int) -> void:
	health_display.update_health_bar(health)


func update_ammo_display(ammo_text: String) -> void:
	ammo_display.update_ammo(ammo_text)


func _on_pause_menu_resume_requested() -> void:
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.resume_game()


func _on_pause_menu_main_menu_requested() -> void:
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.return_to_main_menu()


func _on_pause_menu_quit_requested() -> void:
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.quit_game()
