extends Resource
class_name OrientationHandler2D

class ShapeData:
	var collision_shape: Node2D
	var right_position: Vector2
	var left_position: Vector2

@export var collision_shape_array: Array[OrientationResource]
# Changes all collisionshape2d positions to custom based on input

# have a storable x/y for right and left facing, for each collisionshape2d of an array


