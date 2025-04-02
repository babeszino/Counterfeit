extends CanvasLayer

@onready var health_display : Control = $TopContainer/HealthDisplay
@onready var ammo_display : Label = $BottomContainer/AmmoDisplay
@onready var pause_menu : Control = $PauseMenu
@onready var score_display : Label = $ScoreContainer/VBoxContainer/ScoreDisplay
@onready var killstreak_display : Label = $ScoreContainer/VBoxContainer/KillstreakDisplay
@onready var timer_label : Label = $TimerContainer/TimerLabel
var level_start_time : float = 0

var killstreak_timer : Timer

var player = null


func _ready() -> void:
	health_display.hide_all_health_bars()
	
	killstreak_timer = Timer.new()
	killstreak_timer.wait_time = 2.0
	killstreak_timer.one_shot = true
	killstreak_timer.timeout.connect(_on_killstreak_timer_timeout)
	add_child(killstreak_timer)
	
	var score_system = get_node("/root/ScoreSystem")
	if score_system:
		score_system.connect("score_changed", Callable(self, "update_score_display"))
		score_system.connect("killstreak_updated", Callable(self, "update_killstreak_display"))
	
	killstreak_display.visible = false
	
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
	else:
		update_ammo_display("-- / --")
	
	var level_manager = get_node_or_null("/root/LevelManager")
	if level_manager and level_manager.level_start_time > 0:
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed_time = current_time - level_manager.level_start_time
		update_timer(elapsed_time)


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


func update_score_display(new_score: int) -> void:
	score_display.text = str(new_score)


func update_killstreak_display(streak_type: int, streak_count: int) -> void:
	match streak_type:
		0: # NOTHING
			killstreak_display.visible = false
			killstreak_timer.stop()
		1: # SINGLE_KILL
			killstreak_display.text = "Single kill!"
			killstreak_display.visible = true
			killstreak_timer.start()
		2: # DOUBLE_KILL
			killstreak_display.text = "Double Kill!"
			killstreak_display.visible = true
			killstreak_timer.start()
		3: # TRIPLE_KILL
			killstreak_display.text = "Triple Kill!"
			killstreak_display.visible = true
			killstreak_timer.start()
		4: # MULTI_KILL
			killstreak_display.text = "MULTI KILL!"
			killstreak_display.visible = true
			killstreak_timer.start()
	
	var tween = create_tween()
	tween.tween_property(killstreak_display, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(killstreak_display, "scale", Vector2(1.0, 1.0), 0.1)


func _on_killstreak_timer_timeout() -> void:
	killstreak_display.visible = false


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


func update_timer(elapsed_seconds: float) -> void:
	var minutes = int(elapsed_seconds) / 60
	var seconds = int(elapsed_seconds) % 60
	timer_label.text = "Time: " + str(minutes) + ":" + str(seconds).pad_zeros(2)
