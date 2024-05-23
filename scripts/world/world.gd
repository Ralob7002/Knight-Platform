class_name World
extends Node2D

# Constantes.
const time: Dictionary = {
	morning = [120, 5],
	afternoon = [15, 5], # [time_transition, time_duration]
	night = [60, 5],
} 


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
