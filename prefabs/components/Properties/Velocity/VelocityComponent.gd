extends Node2D
class_name VelocityComponent

@export var root : Node2D # what node are we enacting velocity changes onto
@export var stats_component: Node2D

@export var acceleration_coefficient : float = 100.0
@export var friction : float = 10.0
@export var speed_variance : float = 5.0

func move(delta: float, direction: Vector2):
	var new_velocity = root.velocity.move_toward(direction * stats_component.max_speed, acceleration_coefficient * delta)
	root.velocity.x = clamp(new_velocity.x + randf_range(-speed_variance, speed_variance), -stats_component.max_speed, stats_component.max_speed) 

func apply_friction(delta: float):
	root.velocity = root.velocity.move_toward(Vector2.ZERO, friction * delta)
