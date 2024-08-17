extends Node2D
class_name OrientationHandler2D

# Changes all array node positions to custom based on left and right function call
# Also works for sprites as long as you add them to the sprite resource array
# has a storable x/y for right and left facing, for each node of an array
# Add raycast start and end to seperate arrays

# root is whatever node you want to emit the change orientation signal
@export var root : Node2D

@export var collision_resource_array : Array[OrientationHandler2DResource]
@export var sprite_resource_array : Array[OrientationHandler2DSprite2DResource]
@export var raycast_resource_array : Array[OrientationHandler2DRaycast2DResource]
@onready var arrays : Array[Array] = [collision_resource_array, sprite_resource_array, raycast_resource_array]

var o_h_2d_o = "OrientationHandler2dOffset"
var prev_direction : Vector2

# Dictionary to store NodePaths mapped to their corresponding resources
var nodepath_to_resource : Dictionary = {}

func _ready():
	create_nodepath_to_resource_dictionary()
	add_offset_children()
	root.change_orientation.connect(_change_orientation)

# populate nodepath_to_resource dict
func create_nodepath_to_resource_dictionary():
	for array in arrays:
		for resource in array:
			nodepath_to_resource[resource.node_path] = resource

# add offset nodes to each node
func add_offset_children():
	for array in arrays:
		for resource in array:
			var offset_node = OrientationHandler2DOffset.new()
			offset_node.name = o_h_2d_o
			get_node(resource.node_path).add_child(offset_node)

func face(direction : Vector2):
	for node_path in nodepath_to_resource.keys():
		var resource = nodepath_to_resource[node_path]
		var node = get_node(node_path)
		var offset_node = node.get_node(o_h_2d_o)
		var offset = offset_node.get_offset()
		
		if direction.x > 0:
			node.position = resource.right_position + offset
			if node is Sprite2D:
				node.flip_h = false
			if node is RayCast2D:
				node.target_position = resource.end_right_position + offset
		elif direction.x < 0:
			node.position = resource.left_position - offset
			if node is Sprite2D:
				node.flip_h = true
			if node is RayCast2D:
				node.target_position = resource.end_left_position - offset

# Attach signal to change orientation and input a normalized direction
func _change_orientation(direction : Vector2):
	face(direction)
	prev_direction = direction

# For animations, you need to have it offset somehow!
func _change_offset(node_path: NodePath, offset : Vector2):
	var node = get_node(node_path)
	if node:
		var offset_node = node.get_node(o_h_2d_o)
		if offset_node:
			offset_node.set_offset(offset)
	_change_orientation(prev_direction)
