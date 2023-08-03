## A state machine that can be assigned to anything and uses its child nodes in the scene tree to keep track of and add/remove functionality
class_name StateMachine
extends Node

## Dictionary for holding all the states mapped to their names.
var _states: Dictionary

## The current state that the state machine is in.
var current_state: State

## The previous state that the state machine was in.
var previous_state: State

## The name of the current state.
var current_state_name: String

## The name of the previous state.
var previous_state_name: String

## The actor that contains all the shared state of the object, this will usually be a physics body that the states act upon.
@export var actor: Node

## Signal emitted when any state change occurs.
signal state_changed(new_state: State, previous_state: State)

## Emitted when the state machine is initialised.
signal initialised

var _states_array: Array[State] = []


## This must be called at some point before the processing starts, otherwise the state machine will not work.
## It will iterate over all child nodes in the scene and add them to the state dictionary.
func _ready() -> void:
	# Iterate over the children and find all the states
	for child in get_children():
		if child is State:
			_states_array.append(child)

			# Get the child node's name and add it to the state dictionary
			_states[child.name.to_lower()] = child

			# If the child doesn't have the change_state signal something has probably gone very wrong
			if not child.has_signal("change_state"):
				push_error("State does not have change_state signal: " + child.name)

			# If the child has a shared_state variable then set it to the shared_state variable of this node
			# This will only happen if the state node inherits from State and adds its own shared_state variable, but it isn't
			# strictly necessary
			if "actor" in child:
				child.actor = actor

			# Connect to the change_state signal, and connect any signals that the child node requires
			child.change_state.connect(_change_state)
			child.connect_signals()

		# TODO: Handle child state machines
		if child is StateMachine:
			pass

	_change_state.call_deferred(_states_array.front().name.to_lower())

	initialised.emit()


## Returns all the names of the states in the state machine.
func get_states():
	return _states.keys()


## Private function that handles all the state changes, this will only get called when a child state emits its change_state signal
## This function accepts either the name of the state to change to, or "previous" to go back to the previous state.
func _change_state(state_name: String) -> void:
	if not initialised:
		return
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
		if previous_state != null:
			previous_state.exit(current_state)
		previous_state_name = current_state_name
	current_state_name = state_name
	current_state.enter(previous_state)
	state_changed.emit(state_name, previous_state_name)


## Function for adding a new state to the state machine. Automatically registers the connections to the change_state signal.
func add_state(state: State) -> void:
	if state.name.to_lower() in _states.keys():
		push_error("State already in state dictionary: " + state.name)
		return
	_states[state.name.to_lower()] = state
	if not state.has_signal("change_state"):
		push_error("State does not have change_state signal: " + state.name)
	state.change_state.connect(_change_state)
	if "actor" in state:
		state.actor = actor
	add_child(state)


## Function for removing a state from the state machine. Automatically removes the connections to the change_state signal.
func remove_state(state_name: String) -> void:
	var state = _states.get(state_name.to_lower())
	if state == null:
		push_error("State not in state dictionary: " + state_name)
		return
	if state == current_state:
		push_error("Cannot remove current state: " + state_name)
		return
	if state == previous_state:
		push_error("Cannot remove previous state: " + state_name)
		return
	state.change_state.disconnect(_change_state)
	remove_child(state)
	_states.erase(state_name.to_lower())


## Same as remove_state but accepts a state object instead of a string.
func remove_state_node(state: State) -> void:
	if state == null:
		push_error("State is null")
		return
	remove_state(state.name)
