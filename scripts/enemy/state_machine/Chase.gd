extends Node2D

var enable: bool = false:
	set(value):
		enable = value
		set_physics_process(value)
		if not value:
			disable()

# Sinais.
signal player_detected

# Variáveis.
var ray_cast_state: bool:
	set(value):
		ray_cast_state = value
		if ray_cast_state == true and ray_cast_state != old_ray_cast_state:
			player_detected.emit()
			timer_to_patrol.stop()
		
		elif ray_cast_state == false and ray_cast_state != old_ray_cast_state:
			timer_to_patrol.start()
		
		old_ray_cast_state = ray_cast_state

var old_ray_cast_state: bool
var look_distance: float
var look_speed: float

# Referências.
@onready var sm = $".."
@onready var ray_cast = $RayCast2D
@onready var timer_to_patrol = $TimerToPatrol
@onready var player: CharacterBody2D
@onready var player_cache: CharacterBody2D


func _process(delta):
	if not player:
		look_around(delta)
	
	old_ray_cast_state = ray_cast_state
	if ray_cast.get_collider() and not sm.get_enable("attack"):
		if ray_cast.get_collider().name == "Player":
			ray_cast_state = true
			player = ray_cast.get_collider()
			player_cache = player
		else:
			ray_cast_state = false
	else:
		ray_cast_state = false
	
	if player:
		
		var _position = to_local(player.get_node("CollisionShape2D").global_position)
		ray_cast.target_position.y = _position.y
		
		if abs(_position.x - position.x) < sm.vision_distance:
			ray_cast.target_position.x = _position.x
		else:
			ray_cast.target_position.x = sm.vision_distance * sm.body.direction


func _physics_process(_delta):
	follow_player()
	pass


func setup():
	set_physics_process(enable)
	
	ray_cast.target_position.x = sm.vision_distance * sm.body.direction
	ray_cast.position = sm.vision_position
	
	timer_to_patrol.wait_time = sm.timer_to_patrol
	
	look_distance = sm.look_distance
	look_speed = sm.look_speed


func disable():
	player = null


func follow_player():
	## Faz com que o inimigo siga o player.
	
	var _direction = sm.body.direction
	
	# Inverte a direção do inimigo de acordo com a posição do player.
	if _direction > 0 and global_position.x > player.global_position.x:
		_direction = -_direction
		await get_tree().create_timer(sm.invert_time).timeout
	
	elif _direction < 0 and global_position.x < player.global_position.x:
		_direction = -_direction
		await get_tree().create_timer(sm.invert_time).timeout
	
	sm.body.direction = _direction
	
	# Movimenta o inimigo.
	sm.body.velocity.x = sm.chase_speed * _direction


func look_around(delta):
	
	if look_speed > 0 and ray_cast.target_position.y > look_distance:
		look_speed = -look_speed
		
	elif look_speed < 0 and ray_cast.target_position.y < -look_distance:
		look_speed = -look_speed
	
	if not player:
		ray_cast.target_position.x = look_distance * sm.body.direction
	ray_cast.target_position.y += look_speed * delta


func _on_state_machine_body_changed_direction():
	if not player:
		ray_cast.target_position.x = abs(ray_cast.target_position.x) * sm.body.direction


func _on_player_detected():
	enable = true
	sm.set_enable("patrol", false)


func _on_timer_to_patrol_timeout():
	if not sm.get_enable("attack"):
		if not sm.get_enable("patrol"):
			sm.set_enable("patrol", true)
	enable = false
