extends Node2D

# Sinais.
signal body_changed_direction

# Exportações.
@export var body: CharacterBody2D
@export_group("States Status")
@export var state_status: Dictionary = {
	chase = true,
	patrol = true,
}
@export_category("States")
@export_group("Chase")
@export var timer_to_patrol: float = 2.0
@export_subgroup("Vision")
@export var vision_distance: int
@export var vision_position: Vector2
@export_subgroup("Look Around")
@export var look_time: float = 2
@export var look_distance: int = 50
@export_group("Patrol")
@export var patrol_path: bool = false
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
	body_changed_direction.emit()
