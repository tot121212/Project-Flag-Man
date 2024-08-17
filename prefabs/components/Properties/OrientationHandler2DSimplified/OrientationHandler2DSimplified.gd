extends Node2D

@export var root : Node2D

@export var nodes_to_flip : Array[NodePath]

func _ready():
	root.change_orientation.connect(_change_orientation)

func _change_orientation(direction):
	if direction.x > 0:
		for node_path in nodes_to_flip:
			get_node(node_path).scale.y = abs(get_node(node_path).scale.y)
			get_node(node_path).rotation = deg_to_rad(0)
	
	elif direction.x < 0:
		for node_path in nodes_to_flip:
			get_node(node_path).scale.y = -abs(get_node(node_path).scale.y)
			get_node(node_path).rotation = deg_to_rad(-180)
