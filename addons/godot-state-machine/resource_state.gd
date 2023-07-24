class_name ResourceState
extends Resource

signal change_state(next_state_name: String)
@export var name: String


func enter(previous_state) -> void:
	return


func exit(next_state) -> void:
	return


func handle_input(event: InputEvent) -> void:
	return


func update(delta: float) -> void:
	return


func _on_animation_finished(anim_name: String) -> void:
	return


func connect_signals() -> void:
	pass


func emit_change_state(next_state_name: String) -> void:
	emit_signal("change_state", next_state_name)
