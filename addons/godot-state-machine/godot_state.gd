class_name State
extends Node

signal change_state(next_state_name)

@onready var machine: StateMachine = get_parent()
@onready var shared_state: Resource = get_parent().shared_state


func enter() -> void:
	return


func exit() -> void:
	return


func handle_input(event: InputEvent) -> void:
	return


func update(delta: float) -> void:
	return


func _on_animation_finished(anim_name: String) -> void:
	return
