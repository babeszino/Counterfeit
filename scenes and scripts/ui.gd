extends CanvasLayer

@onready var health_display : Control = $TopContainer/HealthDisplay
@onready var ammo_display : Label = $BottomContainer/AmmoDisplay
@onready var pause_menu : Control = $PauseMenu
@onready var timer_label : Label = $TimerContainer/TimerLabel
@onready var score_display : MarginContainer = $ScoreDisplay

var level_start_time : float = 0
var player = null


func _ready() -> void:
	health_display.visible = false
	ammo_display.visible = false
	timer_label.visible = false
	score_display.visible = false
	
	health_display.hide_all_health_bars()
	
	# connect to player (if it already exists)
	find_player()


func _process(_delta: float) -> void:
	if player == null:
		find_player()
		return
	
	if !is_instance_valid(player):
		health_display.hide_all_health_bars()
		update_ammo_display("-- / --")
		return
	
	if player.health_point != null:
		update_health_bar(player.health_point.hp)
	else:
		health_display.hide_all_health_bars()
	
	var gun = player.get_node_or_null("Gun")
	if gun == null:
		for child in player.get_children():
			if child.has_method("get_ammo_display"):
				gun = child
				break
	
	if gun != null and gun.has_method("get_ammo_display"):
		var ammo_text = gun.get_ammo_display()
		update_ammo_display(ammo_text)
		
		if gun.has_signal("reload_started") and !gun.is_connected("reload_started", Callable(self, "_on_gun_reload_started")):
			gun.connect("reload_started", Callable(self, "_on_gun_reload_started"))
	else:
		update_ammo_display("-- / --")
	
	var level_manager = get_node_or_null("/root/Main/Managers/LevelManager")
	if level_manager and level_manager.level_start_time > 0:
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed_time = current_time - level_manager.level_start_time
		update_timer(elapsed_time)


func find_player() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		set_player(node)
		return


func set_player(player_node) -> void:
	if player != null:
		var old_gun = player.get_node_or_null("Gun")
		if old_gun != null and old_gun.has_signal("reload_started") and old_gun.is_connected("reload_started", Callable(self, "_on_gun_reload_started")):
			old_gun.disconnect("reload_started", Callable(self, "_on_gun_reload_started"))
	
	player = player_node


func update_health_bar(health: int) -> void:
	health_display.update_health_bar(health)


func update_ammo_display(ammo_text: String) -> void:
	ammo_display.update_ammo(ammo_text)


func _on_pause_menu_resume_requested() -> void:
	var game_manager = get_node_or_null("/root/Main/Managers/GameManager")
	if game_manager:
		game_manager.resume_game()


func _on_pause_menu_main_menu_requested() -> void:
	var game_manager = get_node_or_null("/root/Main/Managers/GameManager")
	if game_manager:
		if pause_menu:
			pause_menu.hide()
		
		get_tree().paused = false
		game_manager.return_to_main_menu()


func _on_pause_menu_quit_requested() -> void:
	var game_manager = get_node_or_null("/root/Main/Managers/GameManager")
	if game_manager:
		game_manager.quit_game()


func update_timer(elapsed_seconds: float) -> void:
	var minutes = int(elapsed_seconds) / 60
	var seconds = int(elapsed_seconds) % 60
	timer_label.text = "Time: " + str(minutes) + ":" + str(seconds).pad_zeros(2)


func _on_gun_reload_started(duration: float) -> void:
	if ammo_display and ammo_display.has_method("start_reload_progress"):
		ammo_display.start_reload_progress(duration)


func show_game_ui() -> void:
	$TopContainer.visible = true
	$BottomContainer.visible = true
	$TimerContainer.visible = true
	
	health_display.visible = true
	ammo_display.visible = true
	timer_label.visible = true
	score_display.visible = true


func hide_game_ui() -> void:
	health_display.visible = false
	ammo_display.visible = false
	timer_label.visible = false
	
	if score_display:
		score_display.visible = false
	
	if pause_menu:
		pause_menu.hide()
	
	$TopContainer.visible = false
	$BottomContainer.visible = false
	$TimerContainer.visible = false
