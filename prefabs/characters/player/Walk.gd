extends State
class_name PlayerMovementWalk

@export var root : Node2D
@export var velocity_component : VelocityComponent
@export var gravity_component : GravityComponent
@export var stats_component : StatsComponent
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var player_collision_shape : CollisionObject2D

var holding_down_coefficient = 2

func state_update(_delta):
	root.update_animation_parameters()

var is_falling_through_platform : bool = false

func state_physics_update(delta):
	if root.input_direction.x != 0: # if x direction input
		velocity_component.move(delta, root.input_direction, Vector2(stats_component.max_speed.x, 0))
		if not root.is_attacking:
			root.change_orientation.emit(root.input_direction)
	
	#print("Available Jumps: " + str(root.available_jumps))
	
	if root.is_jumping and (root.input_direction.y >= 0 or root.is_on_roof()): # cancel jump if let go of key or if touching a roof
		#print("Player cancelled jump")
		velocity_component.cancel_jump()
	
	if Input.is_action_just_pressed("up") or (not jump_buffer_timer.is_stopped() and root.is_on_floor()): # if input up or timer running
		if root.is_on_floor(): # if jump from floor
			#print("Player triggered jump from ground")
			root.reset_available_jumps()
			root.set_available_jumps(root.available_jumps - 1) 
			velocity_component.cancel_jump()
			velocity_component.jump()
		elif not coyote_timer.is_stopped() and root.available_jumps > 0: # if jump from air
			#print("Player triggered jump from air")
			root.set_available_jumps(root.available_jumps - 1) 
			velocity_component.cancel_jump()
			velocity_component.jump()
		else:
			jump_buffer_timer.start() # start timer
	
	elif Input.is_action_pressed("down") and not root.is_on_floor(): # if pressing down
		#print("Player inputting down while falling")
		root.velocity.y = move_toward(
			root.velocity.y,
			gravity_component.gravity * holding_down_coefficient, 
			gravity_component.gravity * delta * holding_down_coefficient * root.input_direction.y)
	
	if is_falling_through_platform and not root.is_inside_platform():
		player_collision_shape.set_collision_mask_value(7, true)
		is_falling_through_platform = false
	
	elif Input.is_action_just_pressed("down") and root.is_on_platform(): # and not is_falling_through_platform
		#fall through platform
		is_falling_through_platform = true
		player_collision_shape.set_collision_mask_value(7, false)
	
	if not root.is_jumping:
		velocity_component.apply_friction(delta)
	else:
		velocity_component.apply_friction(delta, 0.8) # 20% less friction if jumping for better mobility in air
		velocity_component.apply_jump(delta)
	
	root.move_and_slide()
