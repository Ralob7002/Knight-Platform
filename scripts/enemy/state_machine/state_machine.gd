extends Node2D

# Sinais.
signal body_changed_direction

# Exportações.
@export var body: CharacterBody2D
@export_group("States Status")
@export var state_status: Dictionary = {
	chase = true,
	patrol = true,
	attack = true,
}
@export_category("States")
@export_group("Chase")
@export var timer_to_patrol: float = 2.0
@export var invert_time: float = 0.2
@export var chase_speed: float = 50
@export_subgroup("Vision")
@export var vision_distance: int = 50
@export var vision_position: Vector2
@export_subgroup("Look Around")
@export var look_speed: float = 400
@export var look_distance: int = 100
@export_group("Patrol")
@export var patrol_path: bool = false
@export var patrol_distance: int = 50
@export_group("Attack")
@export var attack_area: Area2D

# Referências.
@onready var state: Dictionary = {
	chase = $Chase,
	patrol = $Patrol,
	attack = $Attack,
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


func check(state_name):
	if state.has(state_name):
		return true


func get_enable(state_name):
	if state.has(state_name):
		return state[state_name].enable
	else:
		return false


func set_enable(state_name, value):
	if state.has(state_name):
		state[state_name].enable = value


func call_state_method(state_name: String, _method: String):
	Callable(state[state_name], _method).call()


func _on_body_direction_changed():
	body_changed_direction.emit()
