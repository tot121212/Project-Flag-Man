extends Resource
class_name OrientationHandler2DResource

@export var node_path: NodePath

# right and left pos shouldnt be changed at runtime, although add it if u like
@export var right_position: Vector2 = Vector2.ZERO
func get_right_position() -> Vector2:
	return right_position
	
@export var left_position: Vector2 = Vector2.ZERO
func get_left_position() -> Vector2:
	return left_position
