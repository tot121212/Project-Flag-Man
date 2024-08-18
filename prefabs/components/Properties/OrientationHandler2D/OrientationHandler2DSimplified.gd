extends Node2D
class_name OrientationHandler2DSimplified

@export var root : Node2D
@export var nodes_to_flip : Array[NodePath]

func _ready():
	root.change_orientation.connect(_change_orientation)

func _change_orientation(direction):
	for node_path in nodes_to_flip:
		var node = get_node(node_path)
		
		if direction.x > 0:
			if node is Sprite2D or node is AnimatedSprite2D:
				node.flip_h = false
				continue
			node.scale.y = abs(node.scale.y)
			node.rotation = deg_to_rad(0)
		
		elif direction.x < 0:
			if node is Sprite2D or node is AnimatedSprite2D:
				node.flip_h = true
				continue
			node.scale.y = -abs(node.scale.y)
			node.rotation = deg_to_rad(-180)
