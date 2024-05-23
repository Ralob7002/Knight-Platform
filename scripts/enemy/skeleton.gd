extends CharacterBody2D

# Sinais.
signal direction_changed

# Constantes.
const GRAVITY = 980
const speed = 50

# Estados.
var state: Dictionary = {
	idle = false,
	walking = false,
}

# Variáveis.
var direction: int = 1: # Direita.
	set(value):
		direction = value 
		direction_changed.emit()

# Refências.
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var state_machine = $StateMachine


func _process(_delta):
	#for current_state in state:
		#if state[current_state]:
			#print(current_state)
	pass


func _physics_process(delta):
	# Aplica a gravidade.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if not state_machine.state.chase.enable:
		update_state()
	
	# Move o inimigo.
	move_and_slide()
	
	if state_machine.state.chase.enable:
		update_state()
	
	# Atualiza a animação de acordo com o estado.
	update_animation()
	
	# Muda a direção do inimigo caso ele esteja parado e "andando".
	if state.walking and velocity.x == 0 and not state_machine.state.chase.enable:
		direction = -direction


func update_state():
	## Atualiza os estados do inimigo.
	
	if is_on_floor():
		if velocity.x == 0:
			state.idle = true
			state.walking = false
		else:
			state.walking = true
			state.idle = false


func update_animation():
	## Atualiza as animações do inimigo de acordo com o estado.
	
	if state.idle:
		animation_player.current_animation = "idle"
	elif state.walking:
		animation_player.current_animation = "walk"


func _on_direction_changed():
	animated_sprite.flip_h = bool(direction - 1)
	animated_sprite.position.x = abs(animated_sprite.position.x) * direction
