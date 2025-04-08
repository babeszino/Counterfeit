extends Control

@onready var health_display : Control = $TopContainer/HealthDisplay
@onready var ammo_display : Label = $BottomContainer/AmmoDisplay
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
	
	find_player()


func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	
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
	
	var weapon = player.get_node_or_null("Weapon")
	if weapon == null:
		for child in player.get_children():
			if child.has_method("get_ammo_display"):
				weapon = child
				break
	
	if weapon != null and weapon.has_method("get_ammo_display"):
		var ammo_text = weapon.get_ammo_display()
		update_ammo_display(ammo_text)
		
		if weapon.has_signal("reload_started") and !weapon.is_connected("reload_started", Callable(self, "_on_weapon_reload_started")):
			weapon.connect("reload_started", Callable(self, "_on_weapon_reload_started"))
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
		var old_weapon = player.get_node_or_null("Weapon")
		if old_weapon != null and old_weapon.has_signal("reload_started") and old_weapon.is_connected("reload_started", Callable(self, "_on_weapon_reload_started")):
			old_weapon.disconnect("reload_started", Callable(self, "_on_weapon_reload_started"))
	
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


func _on_weapon_reload_started(duration: float) -> void:
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
	if health_display:
		health_display.visible = false
	if ammo_display:
		ammo_display.visible = false
	if timer_label:
		timer_label.visible = false
	if score_display:
		score_display.visible = false
	
	$TopContainer.visible = false
	$BottomContainer.visible = false
	$TimerContainer.visible = false
