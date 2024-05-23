extends Node2D

var enable: bool = false:
	set(value):
		enable = value
		set_physics_process(value)
		sm.body.state.attacking = value

# Referências.
@onready var sm = $".."
@onready var player: CharacterBody2D


func _physics_process(_delta):
	sm.body.velocity.x = 0


func setup():
	set_physics_process(enable)
	
	sm.attack_area.body_entered.connect(on_attack_area_body_entered)
	sm.attack_area.body_exited.connect(on_attack_area_body_exited)


func cause_damage():
	if player:
		player.take_damage()


func check_player():
	if not player:
		enable = false
		if sm.check("chase"):
			#sm.body.direction = -sm.body.direction
			sm.state.chase.player = sm.state.chase.player_cache
			sm.set_enable("chase", true)
		elif not sm.get_enable("patrol"):
			sm.set_enable("patrol", true)


func _on_state_machine_body_changed_direction():
	var _area_collider = sm.attack_area.get_node("CollisionShape2D")
	sm.attack_area.position.x = abs(sm.attack_area.position.x) * sm.body.direction


func on_attack_area_body_entered(body):
	sm.set_enable("chase", false)
	sm.set_enable("patrol", false)
	enable = true
	player = body


func on_attack_area_body_exited(_body):
	player = null
