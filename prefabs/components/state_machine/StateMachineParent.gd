extends Node
class_name StateMachineParent

# lightweight way to trigger transitions between state machines
func transition_state_machine_to_state(state_machine_name : String, state_name : String):
	var state_machine = get_node(state_machine_name)
	if not state_machine:
		print_debug("invalid state machine on transition")
		return
	state_machine.current_state.transition.emit(state_machine.current_state, state_name)

func get_current_state_of_state_machine(state_machine_name : String):
	var state_machine = get_node(state_machine_name)
	if not state_machine:
		print_debug("invalid state machine on transition")
		return
	return state_machine.current_state
