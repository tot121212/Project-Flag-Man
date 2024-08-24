extends Node2D

@export var root : Node2D

var _path_find_2d : TileMapPathFind
var _path : Array[PointInfo] = []
var _target : PointInfo = null
var _prev_target : PointInfo = null
var jump_distance_height_threshold : float = 120.0

func _ready():
	var _path_find_2d = root.find_parent("main").find_child("TileMapPathFind") as TileMapPathFind

func go_to_next_point_in_path():
	if _path.size() <= 0:
		_prev_target = null
		_target = null
		return
	_prev_target = _target
	_target = _path.pop_back()

func do_path_finding(start: Vector2 = root.position, destination : Vector2 = get_global_mouse_position()):
	_path = _path_find_2d.get_platform_2d_path(start, destination)
	go_to_next_point_in_path()
