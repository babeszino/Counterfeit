extends CanvasLayer

@onready var health_bar_container = $TopContainer/HealthBarContainer
@onready var health_bar1 = $TopContainer/HealthBarContainer/HealthBar1
@onready var health_bar2 = $TopContainer/HealthBarContainer/HealthBar2
@onready var health_bar3 = $TopContainer/HealthBarContainer/HealthBar3
@onready var health_bar4 = $TopContainer/HealthBarContainer/HealthBar4
@onready var health_bar5 = $TopContainer/HealthBarContainer/HealthBar5
@onready var ammo_display = $BottomContainer/AmmoDisplay

var player = null


func _ready () -> void:
	hide_all_health_bars()


func _process(_delta: float) -> void:
	if is_instance_valid(player) and player.health_point != null:
		update_health_bar(player.health_point.hp)
		update_ammo_display(player.gun.get_ammo_display())
	else:
		hide_all_health_bars()


func set_player(player_node):
	player = player_node


func hide_all_health_bars() -> void:
	health_bar1.hide()
	health_bar2.hide()
	health_bar3.hide()
	health_bar4.hide()
	health_bar5.hide()


func update_health_bar(health: int) -> void:
	hide_all_health_bars()
	
	if health <= 0:
		return
	elif health <= 20:
		health_bar1.show()
	elif health <= 40:
		health_bar2.show()
	elif health <= 60:
		health_bar3.show()
	elif health <= 80:
		health_bar4.show()
	else:
		health_bar5.show()


func update_ammo_display(ammo_text: String) -> void:
	ammo_display.text = ammo_text
