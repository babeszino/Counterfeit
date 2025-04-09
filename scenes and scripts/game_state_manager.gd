extends Node

signal state_changed(old_state, new_state)

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	LEVEL_COMPLETE,
	GAME_OVER,
	GAME_COMPLETED
}

var current_state = GameState.MAIN_MENU


func _ready():
	var game_manager = get_parent().get_node_or_null("GameManager")
	if game_manager:
		game_manager.connect("game_started", Callable(self, "_on_game_started"))
		game_manager.connect("game_paused", Callable(self, "_on_game_paused"))
		game_manager.connect("game_resumed", Callable(self, "_on_game_resumed"))


func change_state(new_state):
	var old_state = current_state
	current_state = new_state
	
	match new_state:
		GameState.MAIN_MENU:
			get_tree().paused = false
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.LEVEL_COMPLETE:
			pass
		GameState.GAME_OVER:
			pass
		GameState.GAME_COMPLETED:
			pass
			
	emit_signal("state_changed", old_state, new_state)


# signal handling
func _on_game_started():
	change_state(GameState.PLAYING)


func _on_game_paused():
	change_state(GameState.PAUSED)


func _on_game_resumed():
	change_state(GameState.PLAYING)


func _on_game_over():
	change_state(GameState.GAME_OVER)


func is_playing():
	return current_state == GameState.PLAYING


func is_paused():
	return current_state == GameState.PAUSED


func is_in_menu():
	return current_state == GameState.MAIN_MENU
