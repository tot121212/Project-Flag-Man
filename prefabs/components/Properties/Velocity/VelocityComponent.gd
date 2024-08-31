extends Node2D
class_name VelocityComponent

@export var root : Node2D # what node are we enacting velocity changes onto
@export var stats_component: StatsComponent

@export var acceleration_coefficient : float = 100.0
@export var friction : float = 9.0
@export var speed_variance : float = 2.0

var is_jumping : bool = false
var jump_elapsed : float = 0.0

func move(delta: float, direction: Vector2, speed : float):
	var new_velocity = root.velocity.move_toward(direction * speed, acceleration_coefficient * delta)
	root.velocity.x = clamp(new_velocity.x + randf_range(-speed_variance, speed_variance), -stats_component.max_speed.x, stats_component.max_speed.x)
	root.change_orientation.emit(direction)

func jump():
	if not is_jumping:
		is_jumping = true
		jump_elapsed = 0.0
		root.velocity.y = -stats_component.initial_jump_speed

func apply_jump(delta):
	var t = jump_elapsed / stats_component.jump_time
	var new_velocity_y = lerp(
		-stats_component.initial_jump_speed,
		clampf(-stats_component.jump_speed + randf_range(-speed_variance, speed_variance), -stats_component.max_speed.y, stats_component.max_speed.y),
		t
	)
	root.velocity.y = new_velocity_y
	jump_elapsed += delta
	if jump_elapsed >= stats_component.jump_time:
		root.velocity.y = clamp(-stats_component.jump_speed + randf_range(-speed_variance, speed_variance), -stats_component.max_speed.y, stats_component.max_speed.y)
		is_jumping = false

func apply_friction(delta: float):
	root.velocity = root.velocity.move_toward(Vector2.ZERO, friction * delta)
