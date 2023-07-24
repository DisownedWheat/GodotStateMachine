class_name StateMachine
extends Node

var _states: Dictionary
var current_state: State
var previous_state: State
var current_state_name: String
var previous_state_name: String

@export var process = true

signal state_changed(new_state: State, previous_state: State)
signal initialised


func init() -> void:
	for child in get_children():
		if not (child is State):
			continue
		_states[child.name.to_lower()] = child
		if not child.has_signal("change_state"):
			push_error("State does not have change_state signal: " + child.name)
		child.connect("change_state", change_state)
		if child.name == "Idle":
			current_state = child
			current_state.enter(null)
	initialised.emit()


func update(delta: float):
	if not process:
		return
	if current_state == null:
		return
	current_state.update(delta)


func get_states():
	return _states.keys()


func change_state(state_name: String):
	state_name = state_name.to_lower()
	if state_name != "previous" and not state_name in _states:
		push_error("State not in state dictionary: " + state_name)
		return

	if state_name != "previous" and state_name == current_state_name:
		push_warning(
			"Calling state change with current state: " + current_state_name + "->" + state_name
		)
		return

	if state_name == "previous":
		current_state.exit(previous_state)
		current_state = previous_state
		previous_state = null
		previous_state_name = ""
	else:
		previous_state = current_state
		current_state = _states[state_name]
		previous_state.exit(current_state)
		previous_state_name = current_state_name
	current_state_name = state_name
	current_state.enter(previous_state)
	state_changed.emit(state_name, previous_state_name)
