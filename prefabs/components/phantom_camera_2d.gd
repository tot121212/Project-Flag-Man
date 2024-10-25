extends Node2D

@export var phantom_camera_2d : PhantomCamera2D

func _ready():
	await get_tree().process_frame
	#phantom_camera_2d.follow_target = Utils.get_first_player()
	SignalBus.phantom_camera_follow_target.connect(_on_phantom_camera_follow_target)

func _on_phantom_camera_follow_target(target : Node):
	phantom_camera_2d.follow_target = target
