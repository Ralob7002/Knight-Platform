extends Node2D

var enable = false

# Referências.
@onready var sm = $".."
@onready var ray_cast = $RayCast2D


func setup():
	ray_cast.target_position.x = sm.vision_distance
	ray_cast.position = sm.vision_position


func _on_state_machine_direction_changed():
	ray_cast.target_position.x = abs(ray_cast.target_position.x) * sm.body.direction
