extends Node

signal ui_initialized

@onready var ui_container = $"../../UIContainer"
@onready var game_manager = $"../GameManager"
@onready var state_manager = $"../GameStateManager"

var ui_instance = null
var player_ref = null

var ui_elements = {
	"health_display": null,
	"ammo_display": null,
	"score_display": null,
	"timer_label": null,
	"pause_menu": null
}


func _ready():
	if ui_container and ui_container.get_child_count() > 0:
		ui_instance = ui_container.get_child(0)
		
		if ui_instance:
			if state_manager:
				state_manager.connect("state_changed", Callable(self, "_on_game_state_changed"))
			
			ui_elements.health_display = ui_instance.get_node_or_null("TopContainer/HealthDisplay")
			ui_elements.ammo_display = ui_instance.get_node_or_null("BottomContainer/AmmoDisplay")
			ui_elements.score_display = ui_instance.get_node_or_null("ScoreDisplay")
			ui_elements.timer_label = ui_instance.get_node_or_null("TimerContainer/TimerLabel")
			ui_elements.pause_menu = ui_instance.get_node_or_null("PauseMenu")
			
			if ui_elements.pause_menu:
				ui_elements.pause_menu.connect("resume_requested", Callable(self, "_on_resume_requested"))
				ui_elements.pause_menu.connect("main_menu_requested", Callable(self, "_on_main_menu_requested"))
				ui_elements.pause_menu.connect("quit_requested", Callable(self, "_on_quit_requested"))
			
			hide_all_game_ui()
			
			emit_signal("ui_initialized")


func set_player(player_node):
	player_ref = player_node
	
	if player_ref:
		var gun = player_ref.get_node_or_null("Gun")
		if gun and gun.has_signal("reload_started") and ui_elements.ammo_display:
			if not gun.is_connected("reload_started", Callable(self, "_on_gun_reload_started")):
				gun.connect("reload_started", Callable(self, "_on_gun_reload_started"))


func update_health_display(health):
	if ui_elements.health_display and ui_elements.health_display.has_method("update_health_bar"):
		ui_elements.health_display.update_health_bar(health)


func update_ammo_display(ammo_text):
	if ui_elements.ammo_display and ui_elements.ammo_display.has_method("update_ammo"):
		ui_elements.ammo_display.update_ammo(ammo_text)


func update_timer(elapsed_time):
	if ui_elements.timer_label:
		var minutes = int(elapsed_time) / 60
		var seconds = int(elapsed_time) % 60
		ui_elements.timer_label.text = "Time: " + str(minutes) + ":" + str(seconds).pad_zeros(2)


func show_game_ui():
	for element_name in ui_elements:
		var element = ui_elements[element_name]
		if element and element_name != "pause_menu":
			element.visible = true


func hide_all_game_ui():
	for element_name in ui_elements:
		var element = ui_elements[element_name]
		if element:
			element.visible = false


func show_pause_menu():
	if ui_elements.pause_menu:
		ui_elements.pause_menu.visible = true


func hide_pause_menu():
	if ui_elements.pause_menu:
		ui_elements.pause_menu.visible = false


func _on_game_state_changed(old_state, new_state):
	match new_state:
		state_manager.GameState.MAIN_MENU:
			hide_all_game_ui()
		state_manager.GameState.PLAYING:
			show_game_ui()
			hide_pause_menu()
		state_manager.GameState.PAUSED:
			show_pause_menu()


func _on_gun_reload_started(duration):
	if ui_elements.ammo_display and ui_elements.ammo_display.has_method("start_reload_progress"):
		ui_elements.ammo_display.start_reload_progress(duration)


func _on_resume_requested():
	if game_manager:
		game_manager.resume_game()


func _on_main_menu_requested():
	if game_manager:
		game_manager.return_to_main_menu()


func _on_quit_requested():
	if game_manager:
		game_manager.quit_game()


func _process(delta):
	if !player_ref or !is_instance_valid(player_ref):
		return
	
	if player_ref.health_point:
		update_health_display(player_ref.health_point.hp)
	
	var gun = player_ref.get_node_or_null("Gun")
	if !gun:
		for child in player_ref.get_children():
			if child.has_method("get_ammo_display"):
				gun = child
				break
	
	if gun and gun.has_method("get_ammo_display"):
		update_ammo_display(gun.get_ammo_display())
		
		if gun.has_signal("reload_started") and !gun.is_connected("reload_started", Callable(self, "_on_gun_reload_started")):
			gun.connect("reload_started", Callable(self, "_on_gun_reload_started"))
	else:
		update_ammo_display("-- / --")
	
	var level_manager = game_manager.get_node_or_null("../LevelManager")
	if level_manager and level_manager.level_start_time > 0:
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed_time = current_time - level_manager.level_start_time
		update_timer(elapsed_time)
