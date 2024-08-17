extends Node
class_name StateMachine

@export var initial_state : State
var current_state : State
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(on_child_transition)
	
	print(initial_state)
	current_state = initial_state
	if current_state:
		current_state.state_enter()
	else:
		print_debug("no current state")
	_on_state_enter_print_debug(current_state.name)

func _process(delta):
	if current_state:
		current_state.state_update(delta)

func _physics_process(delta):
	if current_state:
		current_state.state_physics_update(delta)

func on_child_transition(state : State, new_state_name : String):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.state_exit()
	
	new_state.state_enter()
	
	current_state = new_state
	_on_state_enter_print_debug(current_state.name)

func _on_state_enter_print_debug(state_name): # for debug
	print_debug(self.name + " changed state to: " + state_name)
