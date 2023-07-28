class_name State
extends Node

signal change_state(next_state_name: String)


func enter(previous_state) -> void:
	set_process(true)
	set_physics_process(true)
	set_process_input(true)


func exit(next_state) -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)


func connect_signals() -> void:
	pass
