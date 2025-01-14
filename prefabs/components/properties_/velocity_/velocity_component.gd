extends Node2D
class_name VelocityComponent

@export var root : Node2D # what node are we enacting velocity changes onto
@export var stats_component: StatsComponent

@export var acceleration_coefficient : Vector2 = Vector2(640.0, 64.0)
@export var friction : float = 256

var jump_elapsed : float = 0.0
var is_jumping : bool = false

signal just_jumped

#For moving via direction
func move(delta: float, direction: Vector2, speed : Vector2, speed_variance : Vector2 = Vector2.ZERO, max_speed : Vector2 = stats_component.max_speed):
	# store new velocity
	var new_velocity : Vector2 = Vector2.ZERO 
	
	# normalize direction
	var direction_normalized = direction.normalized()
	
	# store new velocity, move from root velocity, to normalized direction * speed + speed variance by delta * accel coefficient
	new_velocity.x = move_toward(root.velocity.x, direction_normalized.x * speed.x + speed_variance.x, acceleration_coefficient.x * delta) 
	new_velocity.y = move_toward(root.velocity.y, direction_normalized.y * speed.y + speed_variance.y, acceleration_coefficient.y * delta) 
	
	# store new velocity but clamped to max speed stat which is from the stats component by default
	root.velocity.x = clampf(new_velocity.x, -max_speed.x, max_speed.x)
	root.velocity.y = clampf(new_velocity.y, -max_speed.y, max_speed.y)
	
	return root.velocity

func jump(): # to initiate a jump
	if is_jumping:
		return
	
	is_jumping = true
	jump_elapsed = 0.0
	root.velocity.y = -stats_component.initial_jump_speed
	just_jumped.emit()

func apply_jump(delta, max_speed : Vector2 = stats_component.max_speed): # applying jump over time
	if not is_jumping:
		return
	
	jump_elapsed += delta
	
	# time factor on elapsed time / jump time
	var t = clamp(jump_elapsed / stats_component.jump_time, 0 , 1)
	# ensures the jump is fast to begin and slow at the peak
	var eased_t = ease(t, -4.0)
	
	# linear interpolate between init jump speed and the clamped regular jump speed, by the eased time factor
	var eased_jump_speed = lerp(
		-stats_component.initial_jump_speed,
		clampf(-stats_component.jump_speed, -max_speed.y, max_speed.y),
		eased_t
	)

	# Apply the acceleration factor which is the eased jump speed * 1 + the accel coefficient * delta
	var new_velocity_y = eased_jump_speed * (1 + acceleration_coefficient.y * delta)
	
	root.velocity.y = new_velocity_y # set new velocity
	
	if jump_elapsed >= 1: # if jump finished
		root.velocity.y = clamp(-stats_component.jump_speed, -max_speed.y, max_speed.y)
		is_jumping = false

func cancel_jump(): # for canceling jump if needed
	if is_jumping:
		is_jumping = false


func apply_friction(delta: float, friction_coefficient : float = 1): # for moving x via friction
	root.velocity.x = move_toward(root.velocity.x, 0, (friction * friction_coefficient) * delta)

func take_knockback(knockback): # take knockback in a direction
	root.velocity += knockback
