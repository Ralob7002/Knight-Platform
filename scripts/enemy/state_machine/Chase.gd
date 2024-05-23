extends Node2D

var enable: bool = false:
	set(value):
		enable = value
		set_physics_process(value)

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
var look_time: float

# Referências.
@onready var sm = $".."
@onready var ray_cast = $RayCast2D
@onready var timer_to_patrol = $TimerToPatrol
@onready var player: CharacterBody2D


func _process(_delta):
	#print("chase: " + str(enable))
	#print("current:" + str(ray_cast_state))
	#print("old:" + str(old_ray_cast_state))
	
	old_ray_cast_state = ray_cast_state
	if ray_cast.get_collider():
		if ray_cast.get_collider().name == "Player":
			ray_cast_state = true
			player = ray_cast.get_collider()
		else:
			ray_cast_state = false
	else:
		ray_cast_state = false
	
	if player:
		ray_cast.rotation = 0
		
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
	look_time = sm.look_time


func follow_player():
	## Faz com que o inimigo siga o player.
	
	var _direction = sm.body.direction
	
	# Inverte a direção do inimigo de acordo com a posição do player.
	if _direction > 0 and global_position.x > player.global_position.x:
		_direction = -_direction
		await get_tree().create_timer(0.5).timeout
	
	elif _direction < 0 and global_position.x < player.global_position.x:
		_direction = -_direction
		await get_tree().create_timer(0.5).timeout
	
	sm.body.direction = _direction
	
	# Movimenta o inimigo.
	sm.body.velocity.x = sm.body.speed * _direction


func look_around():
	## Move o ray_cast target no eixo y, permitindo que o inimigo tenha visão vertical.
	
	var tween = create_tween()
	tween.tween_property(ray_cast, "target_position:y", look_distance, look_time/2)
	tween.tween_callback(func():
		tween.kill()
		look_distance = -look_distance
		if not player:
			look_around())


func _on_state_machine_body_changed_direction():
	ray_cast.target_position.x = abs(ray_cast.target_position.x) * sm.body.direction


func _on_player_detected():
	enable = true
	sm.state.patrol.enable = false


func _on_timer_to_patrol_timeout():
	sm.state.patrol.enable = true
	enable = false
	player = null
	ray_cast.target_position.x = sm.vision_distance * sm.body.direction
	pass
