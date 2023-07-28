## A state machine that can be assigned to anything and uses its child nodes in the scene tree to keep track of and add/remove functionality
@tool
class_name OldStateMachine
extends Node

## Sets which process engine method the state machine will use to update the current state.
enum Process_Mode { IDLE, PHYSICS, BOTH }

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

## The resource for storing shared state. If you want this to be passed into the child states they must have a shared_state variable.
var shared_state: SharedState

var _dirty_check: bool = true

## If this is set to false then the state machine will not process any state changes, won't update the current state, and won't process any input events.
@export var process: bool = true

## The script that will be used to create the shared state node. This will be create a new node inside the scene tree that is visible in the editor and the
## exported variables of that node will be able to be edited from inside there
@export var shared_state_class: Script:
	set = _set_shared_state_script

## Determine whhich method the update is to be called from.
@export var state_process_mode: Process_Mode = Process_Mode.PHYSICS

## Signal sent when any state change occurs
signal state_changed(new_state: State, previous_state: State)

## Sent when the state machine is initialised
signal initialised


## This must be called at some point before the processing starts, otherwise the state machine will not work.
## It will iterate over all child nodes in the scene and add them to the state dictionary.
func _ready() -> void:
	_dirty_check = false

	# If we're inside the editor we shouldn't do anything
	if Engine.is_editor_hint():
		return

	# Find the shared state node if it exists
	shared_state = find_child("SharedState")

	# Iterate over the children and find all the states
	for child in get_children():
		if child is State:
			# Get the child node's name and add it to the state dictionary
			_states[child.name.to_lower()] = child

			# If the child doesn't have the change_state signal something has probably gone very wrong
			if not child.has_signal("change_state"):
				push_error("State does not have change_state signal: " + child.name)

			# If the child has a shared_state variable then set it to the shared_state variable of this node
			# This will only happen if the state node inherits from State and adds its own shared_state variable, but it isn't
			# strictly necessary
			if "shared_state" in child:
				child.shared_state = shared_state

			# Connect to the change_state signal, and connect any signals that the child node requires
			child.change_state.connect(_change_state)
			child.connect_signals()

			# If the child node is the idle state then set it as the current state
			if child.name == "Idle":
				current_state = child
				current_state.enter(null)
		if child is StateMachine:
			pass

	# If no current state has been set then just take the first state available and use that
	if current_state == null:
		for child in get_children():
			if not (child is State):
				continue
			current_state = child
			current_state.enter(null)
			break

	initialised.emit()


## This is just a bit of a helper function for checking whether we want the update to run
func update(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not initialised:
		return
	if not process:
		return
	if current_state == null:
		return
	current_state.update(delta)


## Returns all the names of the states in the state machine.
func get_states() -> Array[String]:
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
	if "shared_state" in state:
		state.shared_state = shared_state
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


func _physics_process(delta: float) -> void:
	if state_process_mode == Process_Mode.PHYSICS or state_process_mode == Process_Mode.BOTH:
		update(delta)


func _process(delta: float) -> void:
	if state_process_mode == Process_Mode.IDLE or state_process_mode == Process_Mode.BOTH:
		update(delta)


## Private method that is called when the shared_state_script is added to the state machine. This will create a new node in the scene tree
## and shouldn't be called at runtime
func _set_shared_state_script(shared_state_script: Script) -> void:
	if _dirty_check:
		return
	shared_state_class = shared_state_script

	# Then we create the new shared state and add it to the scene tree
	var tmp_shared_state = shared_state_class.new()
	if not tmp_shared_state is SharedState:
		push_error("Shared state script does not inherit from SharedState")
		return

	# If a SharedState node is already present then we should remove it first
	var child = find_child("SharedState")
	if child != null:
		remove_child(child)
		child.queue_free()

	add_child(tmp_shared_state)
	tmp_shared_state.set_owner(owner)
	tmp_shared_state.name = "SharedState"
