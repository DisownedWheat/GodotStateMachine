class_name ResourceStateMachine
extends Node

# @export var states: Array[ResourceState] = []

var current_state: ResourceState
var _states: Dictionary
var previous_state: ResourceState
signal state_changed(new_state: ResourceState, old_state: ResourceState)

var _initialised = false


func init() -> void:
	_initialised = true
	var states = self.get("states")
	if states == null:
		states = [ResourceState.new()]
	for state in states:
		print(state.name)
		_add_state(state.name, state)
		state.connect("change_state", change_state)
	current_state = states[0]


func change_state(new_state: String) -> void:
	print(new_state)
	if new_state == "previous":
		current_state.exit(previous_state)
		previous_state.enter(current_state)
		current_state = previous_state
	else:
		previous_state = current_state
		current_state = _states.get(new_state)
		if current_state == null:
			push_error("State not found: " + new_state)
		if previous_state == current_state:
			return
		if previous_state != null:
			previous_state.exit(current_state)
		if new_state != null:
			current_state.enter(previous_state)

	state_changed.emit(current_state, previous_state)


func get_transition(_delta: float) -> void:
	pass


func update_state(_delta: float) -> void:
	pass


func _add_state(state_name, state_: RefCounted) -> void:
	_states[state_name] = state_


func _remove_state(state_name) -> void:
	_states.erase(state_name)
