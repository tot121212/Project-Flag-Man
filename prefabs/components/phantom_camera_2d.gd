extends Node2D

@export var phantom_camera_2d : PhantomCamera2D

func _ready():
	await get_tree().process_frame
	#phantom_camera_2d.follow_mode = phantom_camera_2d.FollowMode.PATH
	#phantom_camera_2d.set_follow_path(get_tree().get_first_node_in_group("phantom_camera_2d_follow_path"))
	SignalBus.phantom_camera_follow_target.connect(_on_phantom_camera_follow_target)

func _on_phantom_camera_follow_target(target : Node):
	phantom_camera_2d.follow_target = target
