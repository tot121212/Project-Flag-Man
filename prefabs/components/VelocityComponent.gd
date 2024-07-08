extends Node2D

@export var max_speed := -400.0
@export var acceleration := 2000.0
@export var friction := 1500.0

var velocity := Vector2.ZERO

func apply_acceleration(direction: Vector2, delta: float):
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func apply_friction(delta: float):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func get_velocity() -> Vector2:
	return velocity
