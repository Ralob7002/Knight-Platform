extends CharacterBody2D

# Constantes.
const GRAVITY = 980
const speed = 100
const crouch_speed = 25
const jump_speed = -300

# Estados.
var state: Dictionary = {
	idle = false,
	running = false,
	jumping = false,
	falling = false,
	crouch = false,
}

# Sinais.
signal direction_changed()

# Variáveis.
var direction = 1: # Direita.
	set(value):
		if value != direction:
			direction = value
			direction_changed.emit()


# Referências.
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var collision_shape = $CollisionShape2D


func _process(_delta):
	#for current_state in state:
		#if state[current_state]:
			#print(current_state)
	pass


func _physics_process(delta):
	# Aplica a gravidade se o "Player" não estiver no chão.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	movement()
	update_states()
	update_animation()


func movement():
	## Possibilita que o jogador controle o "Player".
	
	# Muda a velocidade local de acordo com o estado do "Player".
	var _speed
	if state.crouch:
		_speed = crouch_speed
		animation_player.speed_scale = 0.5
	else:
		_speed = speed
		animation_player.speed_scale = 1
	
	# Movimento horizontal.
	var input_direction = Input.get_axis("left", "right")
	velocity.x = input_direction * _speed
	
	# Pulo.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
		
	# Agachar.
	if Input.is_action_just_pressed("crouch"):
		# Inverte o valor (true/false) de "state.crouch".
		state.crouch = not state.crouch
		# Inicia a transição de agachar.
		animation_player.current_animation = "crouch_transition"
	
	# Atualiza a direção do player se "input_direction" for diferente de zero.
	if input_direction:
		direction = input_direction
	
	# Movimenta o "Player".
	move_and_slide()


func update_animation():
	## Atualiza as animações do "Player" de acordo com seu estado.
	
	# Animações do "Player" em pé.
	if not state.crouch:
		if state.idle:
			animation_player.current_animation = "idle"
		elif state.running:
			animation_player.current_animation = "run"
		elif state.jumping:
			animation_player.current_animation = "jump"
		elif state.falling:
			animation_player.current_animation = "fall"
	
	# Animações do "Player" agachado.
	elif state.crouch and animation_player.current_animation != "crouch_transition":
		if state.idle:
			animation_player.current_animation = "crouch"
		elif state.running:
			animation_player.current_animation = "crouch_walk"


func update_states():
	## Atualiza os estados do "Player".
	
	# Verifica se o "Player" está correndo ou parado.
	if is_on_floor() and velocity.x != 0:
		state.running = true
		state.idle = false
		
	else:
		state.running = false
		state.idle = true
		
	# Verifica se o "Player" está pulando ou caindo.
	if not is_on_floor():
		state.idle = false
		
		if velocity.y < 0:
			state.jumping = true
		
		elif velocity.y > 100:
			state.falling = true
			state.jumping = false
		
	else:
		state.jumping = false
		state.falling = false


func _on_direction_changed():
	animated_sprite.flip_h = bool(direction - 1)
	animated_sprite.position.x = abs(animated_sprite.position.x) * direction
	collision_shape.position.x = abs(collision_shape.position.x) * direction


func _on_left_feet_body_entered(body):
	print("LeftFeet touch on ground")
	pass


func _on_right_feet_body_entered(body):
	#print("RightFeet touch on ground")
	pass
