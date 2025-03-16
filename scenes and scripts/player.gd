extends CharacterBody2D

@export var Bullet: PackedScene
@export var speed: float = 200.0

@onready var end_of_gun = $EndOfGun
@onready var attack_cooldown = $AttackCooldown
@onready var firing_effect = $FiringEffect
@onready var firing_animation = $FiringAnimation


func _ready() -> void:
	firing_effect.hide()


func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("up"):
		direction.y -= 1
	
	if Input.is_action_pressed("down"):
		direction.y += 1
	
	if Input.is_action_pressed("left"):
		direction.x -= 1
	
	if Input.is_action_pressed("right"):
		direction.x += 1
	
	direction = direction.normalized()
	
	position += direction * speed * delta
	
	# look where the cursor is at
	look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("fire"):
		shoot()


func shoot():
	if attack_cooldown.is_stopped():
		var bullet_instance = Bullet.instantiate()
		get_parent().add_child(bullet_instance)
	
		bullet_instance.global_position = end_of_gun.global_position
	
		var target = get_global_mouse_position()
		var direction_to_shoot = (target - bullet_instance.global_position).normalized()
		
		bullet_instance.set_direction(direction_to_shoot)
		
		# attack cooldown timer restart
		attack_cooldown.start()
		
		# firing animnation - play
		firing_animation.play("FiringAnimation")
