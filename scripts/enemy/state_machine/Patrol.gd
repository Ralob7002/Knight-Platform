extends Node2D

var enable: bool = true:
	set(value):
		enable = value
		set_physics_process(value)

# Variáveis.
var patrol_position: Dictionary = {
	begin = 0,
	end = 0,
}

# DELETAR.
var current_patrol_position = patrol_position.end

# Referências.
@onready var sm = $".."
@onready var patrol_path = $PatrolPath


func _physics_process(_delta):
	# Atualiza as posições do PatrolPath.
	patrol_path.points[0] = to_local(Vector2(patrol_position.begin.x, global_position.y))
	patrol_path.points[1] = to_local(Vector2(patrol_position.end.x, global_position.y))
	
	# DEBUG.
	if Input.is_action_just_pressed("jump"):
		setup()
	
	# Movimentação.
	if sm.patrol_distance > 0:
		sm.body.velocity.x = sm.body.speed * sm.body.direction
	
	# Inverte a direção se chegar nos limites do caminho de patrulha .
	if patrol_position.end.x > patrol_position.begin.x:
		if sm.body.direction > 0 and global_position.x > patrol_position.end.x:
			sm.body.direction = -sm.body.direction
		elif sm.body.direction < 0 and global_position.x < patrol_position.begin.x:
			sm.body.direction = -sm.body.direction
			
	elif patrol_position.end.x < patrol_position.begin.x:
		if sm.body.direction < 0 and global_position.x < patrol_position.end.x:
			sm.body.direction = -sm.body.direction
		elif sm.body.direction > 0 and global_position.x > patrol_position.begin.x:
			sm.body.direction = -sm.body.direction

func setup():
	set_physics_process(enable)
	
	patrol_position.begin = global_position - (Vector2(sm.patrol_distance, 0) * sm.body.direction)
	patrol_position.end = global_position + (Vector2(sm.patrol_distance, 0) * sm.body.direction)
	
	# Adiciona os pontos do PatrolPath
	patrol_path.points = [to_local(patrol_position.begin), to_local(patrol_position.end)]
