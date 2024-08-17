extends State
class_name PlayerMovementWalk

@export var root : Node2D

func state_physics_update(delta):
	if not root.is_on_floor(): # gravity
		root.velocity.y += root.gravity * delta # enact gravity
		if Input.is_action_pressed("down"): # go quicker down if down is pressed
			root.velocity.y = move_toward(root.velocity.y, root.gravity * 2, root.gravity * delta * 2) # quickly go down if pressing down key
			
	else: # we know we are on the floor
		if root.is_landing == true:
			#play landing sound
			root.is_landing = false
		# jump logic
		if root.direction.y < 0: # if input up, then jump
			root.velocity.y = root.jump_velocity
			root.is_landing = true
	
	if root.direction.x != 0 && root.direction.x == root.prev_direction.x: # move if direction and prev is equal to cur direction.x
		root.x_acceleration *= 1.1
		root.x_acceleration = snapped(root.x_acceleration, root.TWO_DECIMALS)
		root.velocity.x = move_toward(root.velocity.x, root.max_speed, snappedf(root.direction.x * root.min_speed * root.x_acceleration, root.TWO_DECIMALS))
		root.velocity.x = clamp(root.velocity.x, -root.max_speed, root.max_speed)
		
	else: # slow down
		root.x_acceleration = 1.0 # reset acceleration
		root.velocity.x = move_toward(root.velocity.x, 0, root.max_speed * 2.5 * delta)
	
	root.prev_direction = root.direction # save prev direction
	if root.direction.x != 0:
		if not root.is_attacking:
			root.change_orientation.emit(root.direction)
	root.update_animation_parameters()
	root.move_and_slide() # then enact physics
