extends Object

class_name PointInfo

func _init(POINT_ID : int = -1, POSITION : Vector2 = Vector2.ZERO):
	point_id = POINT_ID
	position = POSITION

var is_fall_tile : bool
var is_left_edge : bool
var is_right_edge : bool
var is_left_wall : bool
var is_right_wall : bool
var is_position_point : bool
var point_id : int
var position : Vector2
