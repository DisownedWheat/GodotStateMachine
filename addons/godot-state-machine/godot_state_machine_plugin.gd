tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"StateMachine", "Node",
		preload("res://addons/godot-state-machine/godot_state_machine.gd"),
		preload("res://addons/godot-state-machine/icon.png")
	)
	
	add_custom_type(
		"State", "Node",
		preload("res://addons/godot-state-machine/godot_state.gd"),
		preload("res://addons/godot-state-machine/icon.png")
	)
	
func _exit_tree():
	remove_custom_type("StateMachine")
	remove_custom_type("State")
