extends State
class_name PlayerMovementWalk

@export var root : Node2D
@export var velocity_component : VelocityComponent
@export var gravity_component : GravityComponent
@export var stats_component : StatsComponent
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var player_collision_shape : CollisionObject2D
@export var fmod_event_emitter_2d_jump : FmodEventEmitter2D
@export var fmod_event_emitter_2d_jump_landing : FmodEventEmitter2D
@export var player_speed_modifier : PlayerSpeedModifier
@export var animation_player : AnimationPlayer

var holding_down_coefficient = 2

var is_falling_through_platform : bool = false

func state_physics_update(delta):
	match animation_player.current_animation:
		"":
			animation_player.current_animation = "idle"
	
	if root.input_direction.x != 0: # if x direction input
		if not animation_player.current_animation == "attack":
			root.change_orientation.emit(root.input_direction)
		velocity_component.move(delta, root.input_direction, Vector2(root.get_cur_max_speed().x, 0), Vector2.ZERO, root.get_cur_max_speed())
		
	
	#print("Available Jumps: " + str(root.available_jumps))
	
	if not root.was_on_floor and root.is_on_floor(): # play sound if wasnt on floor but is on floor now
		fmod_event_emitter_2d_jump_landing.play()
	
	if velocity_component.is_jumping and (root.input_direction.y >= 0 or root.is_on_ceiling()): # if jumping and not still inputing jump or is on ceiling, cancel jump
		#print("Player cancelled jump")
		velocity_component.cancel_jump()
		root.reset_available_jumps()
	
	if Input.is_action_just_pressed("up") or (not jump_buffer_timer.is_stopped() and root.is_on_floor()): # if input up or (our input buffer is running and were on the floor, this option locks us into the is on floor option)
		if root.is_on_floor(): # if jump from floor
			#print("Player triggered jump from ground")
			root.reset_available_jumps()
			execute_jump()
		
		elif not coyote_timer.is_stopped() and root.available_jumps > 0: # if jump from air
			#print("Player triggered jump from air")
			execute_jump()
		
		else: # start input buffer, it is fine to keep restarting this if up action pressed because we want to store the most recent jump input anyways
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
	
	if not velocity_component.is_jumping:
		velocity_component.apply_friction(delta)
	else:
		velocity_component.apply_friction(delta, 0.8) # 20% less friction if jumping for better mobility in air
		velocity_component.apply_jump(delta, root.get_cur_max_speed())
	
	if root.is_on_floor():
		root.was_on_floor = true
	else:
		root.was_on_floor = false
	
	root.move_and_slide()

func execute_jump():
	velocity_component.cancel_jump() # cancel a jump if any
	root.set_available_jumps(root.available_jumps - 1)
	var ratio = snappedf((player_speed_modifier.stored_jumps / player_speed_modifier.max_stored_jumps), 0.01) # ratio between stored jumps and maximum
	fmod_event_emitter_2d_jump.set_parameter("Pitch", ratio)
	fmod_event_emitter_2d_jump.play()
	velocity_component.jump()
