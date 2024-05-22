extends Node2D

# Exportações.
@export var body: CharacterBody2D
@export_group("States Status")
@export var state_status: Dictionary = {
	chase = true,
	patrol = true,
}
@export_category("States")
@export_group("Chase")
@export_subgroup("Vision")
@export var vision_distance: int
@export var vision_position: Vector2
@export_group("Patrol")
@export var patrol_distance: int

# Referências.
@onready var state: Dictionary = {
	chase = $Chase,
	patrol = $Patrol,
}


func _ready():
	# Conecta o sinal de mudança de direção do corpo.
	body.direction_changed.connect(_on_body_direction_changed)
	
	# Remove estados desativados.
	for index in state_status:
		if state_status[index] == false:
			state.erase(index)
			remove_child(get_node(index.capitalize()))
	
	# Configura estados ativados.
	for index in state:
		state[index].setup()


func _on_body_direction_changed():
	print("ok")
