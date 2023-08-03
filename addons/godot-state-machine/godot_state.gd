class_name State
extends Node

signal change_state(next_state_name: String)


func _ready() -> void:
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	set_block_signals(true)


func enter(previous_state) -> void:
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	set_block_signals(false)


func exit(next_state) -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_block_signals(true)


func connect_signals() -> void:
	pass
