extends CharacterBody2D

# Sinais.
signal direction_changed

# Constantes.
const GRAVITY = 980
const speed = 50
const patrol_distance = 100

# Estados.
var state: Dictionary = {
	idle = false,
	walking = false,
}

var state_machine: Dictionary = {
	patrol = false,
}

# Variáveis.
var direction: int = 1: # Direita.
	set(value):
		direction = value 
		direction_changed.emit()

var patrol_position: Dictionary = {
	begin = 0,
	end = 0,
}

var current_patrol_position = patrol_position.end

# Refências.
@onready var patrol_path = $PatrolPath
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer


func _ready():
	setup_patrol()
	# Adiciona os pontos do PatrolPath
	patrol_path.points = [to_local(patrol_position.begin), to_local(patrol_position.end)]


func _process(_delta):
	# Atualiza as posições do PatrolPath.
	patrol_path.points[0] = to_local(Vector2(patrol_position.begin.x, global_position.y))
	patrol_path.points[1] = to_local(Vector2(patrol_position.end.x, global_position.y))
	
	if Input.is_action_just_pressed("jump"):
		patrol_position.begin = global_position
		patrol_position.end = global_position + (Vector2(patrol_distance, 0) * direction)


func _physics_process(delta):
	# Aplica a gravidade.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	update_state_machine()
	update_state()
	update_animation()
	
	# Move o inimigo.
	move_and_slide()


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


func update_state_machine():
	## Atualiza os estados de máquina do inimigo.
	
	# Movimentação do estado de patrulha.
	if state_machine.patrol:
		patrol()


func patrol():
	# Movimentação.
	velocity.x = speed * direction
	
	# Inverte a direção se chegar nos limites do caminho de patrulha .
	if patrol_position.end.x > patrol_position.begin.x:
		if direction > 0 and global_position.x > patrol_position.end.x:
			direction = -direction
		elif direction < 0 and global_position.x < patrol_position.begin.x:
			direction = -direction
			
	elif patrol_position.end.x < patrol_position.begin.x:
		if direction < 0 and global_position.x < patrol_position.end.x:
			direction = -direction
		elif direction > 0 and global_position.x > patrol_position.begin.x:
			direction = -direction


func setup_patrol():
	patrol_position.begin = global_position
	patrol_position.end = global_position + (Vector2(patrol_distance, 0) * direction)


func _on_direction_changed():
	animated_sprite.flip_h = bool(direction - 1)
	animated_sprite.position.x = abs(animated_sprite.position.x) * direction
