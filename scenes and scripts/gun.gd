extends Node2D

class_name Gun

@export var Bullet : PackedScene

@onready var end_of_gun = $EndOfGun
@onready var attack_cooldown = $AttackCooldown
@onready var firing_effect = $FiringEffect
@onready var firing_animation = $FiringAnimation


func shoot():
	if attack_cooldown.is_stopped():
		var bullet_instance = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet_instance)
	
		bullet_instance.global_position = end_of_gun.global_position
	
		var target = get_global_mouse_position()
		var direction_to_shoot = (target - bullet_instance.global_position).normalized()
		
		bullet_instance.set_direction(direction_to_shoot)
		
		# attack cooldown timer restart
		attack_cooldown.start()
		
		# firing animnation - play
		firing_animation.play("FiringAnimation")
