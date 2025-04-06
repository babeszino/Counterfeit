extends Node

signal score_changed(new_score)
signal killstreak_updated(streak_type, streak_count)

@onready var game_manager = $"../GameManager"

enum KillstreakType {
	NONE,
	SINGLE_KILL,
	DOUBLE_KILL,
	TRIPLE_KILL,
	MULTI_KILL
}

var score : int = 0
var current_killstreak : int = 0

var double_kill_timer : Timer
var triple_kill_timer : Timer 
var multi_kill_timer : Timer


func _ready() -> void:
	double_kill_timer = Timer.new()
	double_kill_timer.name = "DoubleKillTimer"
	double_kill_timer.wait_time = 3.0
	double_kill_timer.one_shot = true
	double_kill_timer.timeout.connect(_on_double_kill_timer_timeout)
	add_child(double_kill_timer)
	
	triple_kill_timer = Timer.new()
	triple_kill_timer.name = "TripleKillTimer"
	triple_kill_timer.wait_time = 2.0
	triple_kill_timer.one_shot = true
	triple_kill_timer.timeout.connect(_on_triple_kill_timer_timeout)
	add_child(triple_kill_timer)
	
	multi_kill_timer = Timer.new()
	multi_kill_timer.name = "MultiKillTimer"
	multi_kill_timer.wait_time = 1.5
	multi_kill_timer.one_shot = true
	multi_kill_timer.timeout.connect(_on_multi_kill_timer_timeout)
	add_child(multi_kill_timer)
	
	await get_tree().process_frame
	
	if game_manager:
		if !game_manager.is_connected("enemy_killed", Callable(self, "register_kill")):
			game_manager.connect("enemy_killed", Callable(self, "register_kill"))


func register_kill() -> void:
	add_score(100)
	
	current_killstreak += 1
	
	if current_killstreak == 1:
		double_kill_timer.start()
		emit_signal("killstreak_updated", KillstreakType.SINGLE_KILL, current_killstreak)
	
	elif current_killstreak == 2:
		double_kill_timer.stop()
		triple_kill_timer.start()
		emit_signal("killstreak_updated", KillstreakType.DOUBLE_KILL, current_killstreak)
	
	elif current_killstreak == 3:
		triple_kill_timer.stop()
		multi_kill_timer.start()
		emit_signal("killstreak_updated", KillstreakType.TRIPLE_KILL, current_killstreak)
	
	elif current_killstreak >= 4:
		emit_signal("killstreak_updated", KillstreakType.MULTI_KILL, current_killstreak)
		multi_kill_timer.stop()
		multi_kill_timer.start()


func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)


func _on_double_kill_timer_timeout() -> void:
	if current_killstreak == 1:
		current_killstreak = 0
		emit_signal("killstreak_updated", KillstreakType.NONE, 0)


func _on_triple_kill_timer_timeout() -> void:
	if current_killstreak == 2:
		add_score(25)
		current_killstreak = 0
		emit_signal("killstreak_updated", KillstreakType.NONE, 0)


func _on_multi_kill_timer_timeout() -> void:
	if current_killstreak >= 3:
		if current_killstreak == 3:
			add_score(50)
		
		elif current_killstreak >= 4:
			add_score(100)
		
		current_killstreak = 0
		emit_signal("killstreak_updated", KillstreakType.NONE, 0)


func reset_score() -> void:
	score = 0
	current_killstreak = 0
	
	double_kill_timer.stop()
	triple_kill_timer.stop()
	multi_kill_timer.stop()
	
	emit_signal("score_changed", score)
	emit_signal("killstreak_updated", KillstreakType.NONE, 0)


func apply_multiplier(multiplier: float) -> void:
	var original_score = score
	score = int(score * multiplier)
	
	emit_signal("score_changed", score)
