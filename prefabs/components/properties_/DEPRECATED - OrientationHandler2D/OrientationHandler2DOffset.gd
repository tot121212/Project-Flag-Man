extends Node2D
class_name OrientationHandler2DOffset

# offset will be changed at runtime with set or get function
var offset : Vector2 = Vector2.ZERO
func get_offset() -> Vector2:
	return offset
func set_offset(i : Vector2):
	offset = i
