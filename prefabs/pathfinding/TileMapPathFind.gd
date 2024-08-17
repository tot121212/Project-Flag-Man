extends TileMap
class_name TileMapPathFind

class PointInfo:
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

@export var show_debug_graph : bool = true
const COLLISION_LAYER : int          = 1
const CELL_IS_EMPTY : int            = -1
const MAX_TIME_FALL_SCAN_DEPTH : int = 500

var _astar_graph : AStar2D = AStar2D.new()
var _used_tiles : Array[Vector2i]
var _graph_point : PackedScene
var _point_info_list : Array[PointInfo]

func _ready():
	_graph_point = ResourceLoader.load("res://prefabs/pathfinding/GraphPoint.tscn")
	_used_tiles = get_used_cells(COLLISION_LAYER)
	build_graph()

func build_graph():
	add_graph_points()

func add_graph_points():
	for tile in _used_tiles:
		add_left_edge_point(tile)

func add_left_edge_point(tile : Vector2i):
	pass

func tile_above_exists(tile : Vector2i):
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x, tile.y - 1)) == CELL_IS_EMPTY:
		pass
	pass
