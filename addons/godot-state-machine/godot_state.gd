class_name State
extends Node

signal change_state(next_state_name: String)

var active = false


func enter(previous_state) -> void:
	active = true


func exit(next_state) -> void:
	active = false


func handle_input(event: InputEvent) -> void:
	return


func update(delta: float) -> void:
	return


func _on_animation_finished(anim_name: String) -> void:
	return


func connect_signals() -> void:
	pass