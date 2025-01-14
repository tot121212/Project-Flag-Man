extends Node2D
class_name OrientationHandler2DSimplified

@export var root : Node2D
@export var nodes_to_flip : Array[NodePath]
@export var ignore_diagonals : bool = true
@export var start_facing_right = true
@export var ignore_orientation_changes : bool = false ## var to ignore any inputs to change orientation

func _ready():
	root.change_orientation.connect(_on_change_orientation)
	if not start_facing_right:
		root.change_orientation.emit(Vector2.LEFT)

var last_direction : Vector2 = Vector2.RIGHT
func _on_change_orientation(direction):
	direction = Vector2(snappedf(direction.x, 0.01), snappedf(direction.y, 0.01))
	if not ignore_orientation_changes:
		if last_direction != direction:
			for node_path in nodes_to_flip:
				var node = get_node_or_null(node_path)
				if node:
					if direction.x > 0:
						node.scale.x = abs(node.scale.x)
					elif direction.x < 0:
						node.scale.x = -abs(node.scale.x)
					
					if not ignore_diagonals:
						if direction.x > 0:
							node.rotation = Vector2.RIGHT.angle_to(direction)
						elif direction.x < 0:
							node.rotation = Vector2.LEFT.angle_to(direction)
						else: # only do these if x is 0
							node.rotation = Vector2.RIGHT.angle_to(direction)
						
			last_direction = direction
			#print(root.name + " changed orientation to:" + str(direction))
