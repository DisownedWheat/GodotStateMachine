# class_name StateMachine
# extends Node

# var state
# var previous_state
# signal state_changed(new_state, old_state)

# func change_state(new_state) -> void:
# 	previous_state = state
# 	state = new_state
# 	if previous_state == state:
# 		return
# 	if previous_state != null:
# 		exit_state(previous_state, state)
# 	if new_state != null:
# 		enter_state(state, previous_state)

# 	emit_signal("state_changed", state, previous_state)

# func enter_state(new_state, old_state) -> void:
# 	pass

# func exit_state(old_state, new_state) -> void:
# 	pass

# func get_transition(delta: float) -> void:
# 	pass

# func update_state(delta: float) -> void:
# 	pass
