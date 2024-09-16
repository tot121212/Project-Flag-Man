extends Node2D
class_name OrientationHandler2DSimplified

@export var root : Node2D
@export var nodes_to_flip : Array[NodePath]
@export var ignore_diagonals : bool = true
var last_direction : Vector2 = Vector2.RIGHT
@export var start_facing_right = true

func _ready():
	if not start_facing_right:
		_change_orientation(Vector2.LEFT)
	root.change_orientation.connect(_change_orientation)

func _change_orientation(direction):
	last_direction = direction
	for node_path in nodes_to_flip:
		var node = get_node_or_null(node_path)
		if node:
			if ignore_diagonals:
				if direction.x > 0:
					node.scale.x = abs(node.scale.x)
				elif direction.x < 0:
					node.scale.x = -abs(node.scale.x)
			else:
				if direction.x > 0 or direction.y < 0:
					node.scale.x = abs(node.scale.x)
					root.rotation = fmod(Vector2.RIGHT.angle_to(direction), PI)
				elif direction.x < 0 or direction.y > 0:
					node.scale.x = -abs(node.scale.x)
					root.rotation = fmod(Vector2.LEFT.angle_to(direction), PI)
