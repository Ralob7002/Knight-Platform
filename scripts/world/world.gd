class_name World
extends Node2D

# Constantes.
const time: Dictionary = {
	morning = [5, 60],
	afternoon = [5, 15], # [time_transition, time_duration]
	night = [5, 30],
} 


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
