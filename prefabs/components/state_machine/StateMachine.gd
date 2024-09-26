extends Node
class_name StateMachine

@export var initial_state : State
var current_state : State
var previous_state : State
var states : Dictionary = {}

func _ready():
	if not initial_state:
		print_debug("No initial state")
		return
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(on_child_transition)
	
	current_state = initial_state
	if current_state:
		current_state.state_enter()
		_on_state_enter_print(current_state.name, initial_state.name)
	else:
		print_debug("no current state")

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
	
	previous_state = current_state
	current_state = new_state
	_on_state_enter_print(current_state.name, previous_state.name)

func _on_state_enter_print(state_name, prev_state_name): # for debug
	print_debug(self.name + " changed state from: " + prev_state_name + " to state: " + state_name)
