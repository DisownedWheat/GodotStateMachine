extends Node

class_name StateMachine

var _states: Dictionary
var current_state: State
var current_state_name: String
var state_stack = []

signal state_changed(state_stack)

func _ready():
	for child in get_children():
		if not (child is State):
			continue
		_states[child.name.to_lower()] = child
		if not child.has_signal("change_state"):
			push_error("State does not have change_state signal: " + child.name)
		child.connect("change_state", self, 'change_state')
		if child.name == "Idle":
			current_state = child
			current_state.enter()

func _physics_process(delta):
	if current_state == null:
		return
	current_state.update(delta)

func change_state(state_name: String, push=false):
	state_name = state_name.to_lower()
	if state_name != "previous" and not state_name in _states:
		push_error("State not in state dictionary: " + state_name)
		return
	
	if current_state:
		current_state.exit()
	if state_name == "previous":
		state_stack.pop_front()
	if push:
		state_stack.push_front(_states[state_name])
	else:
		var new_state = _states[state_name]
		state_stack.push_front(new_state)
	
	current_state = state_stack.pop_front()
	current_state_name = state_name
	if state_name != "previous":
		current_state.enter()
	emit_signal("state_changed", state_stack)
