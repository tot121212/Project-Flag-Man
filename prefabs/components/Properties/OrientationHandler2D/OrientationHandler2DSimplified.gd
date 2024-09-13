extends Node2D
class_name OrientationHandler2DSimplified

@export var root : Node2D
@export var nodes_to_flip : Array[NodePath]
var last_direction : Vector2 = Vector2.RIGHT
@export var change_rotation : bool = true ## ignore this if not using rotation

func _ready():
	root.change_orientation.connect(_change_orientation)

func _change_orientation(direction):
	last_direction = direction
	for node_path in nodes_to_flip:
		var node = get_node_or_null(node_path)
		if node:
			if direction.x > 0:
				if node is Sprite2D or node is AnimatedSprite2D:
					node.flip_h = false
					continue
				if change_rotation:
					node.scale.y = abs(node.scale.y)
					node.rotation = deg_to_rad(0)
				else:
					node.scale.x = abs(node.scale.x)
			elif direction.x < 0:
				if node is Sprite2D or node is AnimatedSprite2D:
					node.flip_h = true
					continue
				if change_rotation:
					node.scale.y = -abs(node.scale.y)
					node.rotation = deg_to_rad(-180)
				else:
					node.scale.x = abs(node.scale.x)
