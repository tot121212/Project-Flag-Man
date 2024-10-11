extends Node2D
class_name VelocityComponent

@export var root : Node2D # what node are we enacting velocity changes onto
@export var stats_component: StatsComponent

@export var acceleration_coefficient : Vector2 = Vector2(640.0, 64.0)
@export var friction : float = 256

#For moving via direction
func move(delta: float, direction: Vector2, speed : Vector2, speed_variance : Vector2 = Vector2.ZERO):
	var new_velocity : Vector2 = Vector2.ZERO
	
	var direction_normalized = direction.normalized()
	#print("direction_normalized: " + str(direction_normalized))
	
	new_velocity.x = move_toward(root.velocity.x, direction_normalized.x * speed.x, acceleration_coefficient.x * delta) + speed_variance.x
	new_velocity.y = move_toward(root.velocity.y, direction_normalized.y * speed.y, acceleration_coefficient.y * delta) + speed_variance.y
	#print("new_velocity: " + str(new_velocity))
	
	root.velocity.x = clampf(new_velocity.x, -stats_component.max_speed.x, stats_component.max_speed.x)
	root.velocity.y = clampf(new_velocity.y, -stats_component.max_speed.y, stats_component.max_speed.y)
	#print("root.velocity: " + str(root.velocity))
	
	return root.velocity

var jump_elapsed : float = 0.0

func jump():
	if not root.is_jumping:
		#print("Root is now jumping")
		root.is_jumping = true
		jump_elapsed = 0.0
		root.velocity.y = -stats_component.initial_jump_speed

func apply_jump(delta):
	if root.is_jumping:
		var t = jump_elapsed / stats_component.jump_time
		var new_velocity_y = lerp(
			-stats_component.initial_jump_speed,
			clampf(-stats_component.jump_speed, 
				-stats_component.max_speed.y, 
				stats_component.max_speed.y), 
			t)
		root.velocity.y = new_velocity_y
		jump_elapsed += delta
		if t >= 1: # if jump finished
			root.velocity.y = clamp(
				-stats_component.jump_speed, 
				-stats_component.max_speed.y, 
				stats_component.max_speed.y)
			#print("Root is no longer jumping")
			root.is_jumping = false

func cancel_jump(): # jump must cancel before triggering new one
	if root.is_jumping:
		root.is_jumping = false

# for moving x via friction
func apply_friction(delta: float, friction_coefficient : float = 1):
	root.velocity.x = move_toward(root.velocity.x, 0, (friction * friction_coefficient) * delta)
