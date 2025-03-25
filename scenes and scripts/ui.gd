extends CanvasLayer

@onready var health_bar_container = $TopContainer/HealthBarContainer
@onready var health_bar1 = $TopContainer/HealthBarContainer/HealthBar1
@onready var health_bar2 = $TopContainer/HealthBarContainer/HealthBar2
@onready var health_bar3 = $TopContainer/HealthBarContainer/HealthBar3
@onready var health_bar4 = $TopContainer/HealthBarContainer/HealthBar4
@onready var health_bar5 = $TopContainer/HealthBarContainer/HealthBar5
@onready var ammo_display = $BottomContainer/AmmoDisplay

var player = null


func _ready() -> void:
	hide_all_health_bars()
	
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
			hide_all_health_bars()
		
		# display ammo
		var gun = player.get_node("Gun")
		update_ammo_display(gun.get_ammo_display())
	else:
		hide_all_health_bars()


func find_player() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		set_player(node)
		return


func set_player(player_node) -> void:
	player = player_node
	print("UI connected to player")


func hide_all_health_bars() -> void:
	if health_bar1: health_bar1.hide()
	if health_bar2: health_bar2.hide()
	if health_bar3: health_bar3.hide()
	if health_bar4: health_bar4.hide()
	if health_bar5: health_bar5.hide()


func update_health_bar(health: int) -> void:
	hide_all_health_bars()
	
	if health <= 0:
		return
	elif health <= 20:
		if health_bar1: health_bar1.show()
	elif health <= 40:
		if health_bar2: health_bar2.show()
	elif health <= 60:
		if health_bar3: health_bar3.show()
	elif health <= 80:
		if health_bar4: health_bar4.show()
	else:
		if health_bar5: health_bar5.show()


func update_ammo_display(ammo_text: String) -> void:
	if ammo_display:
		ammo_display.text = ammo_text
