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
const COLLISION_LAYER : int          = 0
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
		add_right_edge_point(tile)
		add_left_wall_point(tile)
		add_right_wall_point(tile)

func tile_already_exists_in_graph(tile : Vector2i):
	# map position to screen coords
	var local_pos = map_to_local(tile)
	# if a point exists in the graph at all
	if _astar_graph.get_point_count() > 0: 
		# find closest point in graph
		var point_id = _astar_graph.get_closest_point(local_pos) 
		# if that points position is equal to the local position
		if _astar_graph.get_point_position(point_id) == local_pos:
			return point_id
	return -1

func add_visual_point(tile : Vector2i, color : Color = Color(), scale_l : float = 1.0): # cant use scale keyword as that is defined under node2d, must use scale_l
	if not show_debug_graph: return                          # dont show point if not in debug
	var visual_point = _graph_point.instantiate() as Sprite2D# instantiate a new visual point
	if color != Color():                                     # if default color is different, then modulate color
		visual_point.modulate = color
	if scale_l != 1.0 and scale_l > 0.1:                         # if scale is different and valid, change
		visual_point.scale = Vector2(scale_l, scale_l)
	visual_point.position = map_to_local(tile)               # map position of visual point to local coords
	add_child(visual_point)                                  # add child to scene

func add_left_edge_point(tile : Vector2i):
	if tile_above_exists(tile): # if tile above, its not an edge
		return
	# if tile to left is empty, (x - 1) we are on left edge
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x - 1, tile.y)) == CELL_IS_EMPTY:
		var tile_above = Vector2i(tile.x, tile.y - 1) # get above tile
		var existing_point_id = tile_already_exists_in_graph(tile_above)      # get existing point id if exists
		if existing_point_id == -1:                                           # if point doesnt exist
			var point_id = _astar_graph.get_available_point_id()              # get new point id
			var point_info = PointInfo.new(point_id, map_to_local(tile_above))# make a new point info object
			point_info.is_left_edge = true                                    # flag edge
			_point_info_list.append(point_info)                               # append that point info to the list/array
			_astar_graph.add_point(point_id, map_to_local(tile_above))        # add that point to astar graph with id and position locally 
			add_visual_point(tile_above)
		else:                                                                 # point exists
			for point_info in _point_info_list:                               
				if point_info.point_id == existing_point_id:                  # flag that existing point is a left edge if it matches id
					point_info.is_left_edge = true
					add_visual_point(tile_above, Color("#73eff7"))
					break

func add_right_edge_point(tile : Vector2i):
	if tile_above_exists(tile): # if tile above, its not an edge
		return
	# if tile to right is empty, (x + 1) we are on left edge
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x + 1, tile.y)) == CELL_IS_EMPTY:
		var tile_above = Vector2i(tile.x, tile.y - 1) # get above tile
		var existing_point_id = tile_already_exists_in_graph(tile_above)      # get existing point id if exists
		if existing_point_id == -1:                                           # if point doesnt exist
			var point_id = _astar_graph.get_available_point_id()              # get new point id
			var point_info = PointInfo.new(point_id, map_to_local(tile_above))# make a new point info object
			point_info.is_right_edge = true                                    # flag edge
			_point_info_list.append(point_info)                               # append that point info to the list/array
			_astar_graph.add_point(point_id, map_to_local(tile_above))        # add that point to astar graph with id and position locally 
			add_visual_point(tile_above, Color("#94b0c2"))
		else:                                                                 # point exists
			for point_info in _point_info_list:                               
				if point_info.point_id == existing_point_id:                  # flag that existing point is a left edge if it matches id
					point_info.is_right_edge = true
					add_visual_point(tile_above, Color("#ffcd75"))
					break

func add_left_wall_point(tile : Vector2i):
	if tile_above_exists(tile): # if tile above, its not an edge
		return
	# if tile to left up is empty, (x - 1, y - 1) we are on left edge
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x - 1, tile.y - 1)) != CELL_IS_EMPTY:
		var tile_above = Vector2i(tile.x, tile.y - 1) # get above tile
		var existing_point_id = tile_already_exists_in_graph(tile_above)      # get existing point id if exists
		if existing_point_id == -1:                                           # if point doesnt exist
			var point_id = _astar_graph.get_available_point_id()              # get new point id
			var point_info = PointInfo.new(point_id, map_to_local(tile_above))# make a new point info object
			point_info.is_left_wall = true                                    # flag edge
			_point_info_list.append(point_info)                               # append that point info to the list/array
			_astar_graph.add_point(point_id, map_to_local(tile_above))        # add that point to astar graph with id and position locally 
			add_visual_point(tile_above, Color(0,0,0,1))
		else:                                                                 # point exists
			for point_info in _point_info_list:                               
				if point_info.point_id == existing_point_id:                  # flag that existing point is a left edge if it matches id
					point_info.is_left_wall = true
					add_visual_point(tile_above, Color(0,0,1,1), 0.45)
					break

func add_right_wall_point(tile : Vector2i):
	if tile_above_exists(tile): # if tile above, its not an edge
		return
	# if tile to right up is empty, (x + 1, y - 1) we are on left edge
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x + 1, tile.y - 1)) != CELL_IS_EMPTY:
		var tile_above = Vector2i(tile.x, tile.y - 1) # get above tile
		var existing_point_id = tile_already_exists_in_graph(tile_above)      # get existing point id if exists
		if existing_point_id == -1:                                           # if point doesnt exist
			var point_id = _astar_graph.get_available_point_id()              # get new point id
			var point_info = PointInfo.new(point_id, map_to_local(tile_above))# make a new point info object
			point_info.is_right_wall = true                                    # flag edge
			_point_info_list.append(point_info)                               # append that point info to the list/array
			_astar_graph.add_point(point_id, map_to_local(tile_above))        # add that point to astar graph with id and position locally 
			add_visual_point(tile_above, Color(0,0,0,1))
		else:                                                                 # point exists
			for point_info in _point_info_list:                               
				if point_info.point_id == existing_point_id:                  # flag that existing point is a left edge if it matches id
					point_info.is_right_wall = true
					add_visual_point(tile_above, Color("#566c86"), 0.65)
					break

func get_point_info(tile : Vector2i):
	for point_info in _point_info_list:
		if point_info.position == map_to_local(tile):
			return point_info
	return null

func get_start_scan_tile_for_fall_points(tile : Vector2i):
	var tile_above = Vector2(tile.x, tile.y - 1)
	var point = get_point_info(tile_above)
	if point == null: return null
	var tile_scan = Vector2i.ZERO
	if point.is_left_edge:
		tile_scan = Vector2i(tile.x - 1, tile.y - 1) # set start position to scan one tile to the left
		return tile_scan
	if point.is_right_edge:
		tile_scan = Vector2i(tile.x + 1, tile.y - 1) # set start position to scan one tile to the right
		return tile_scan
	return null

func find_fall_point(tile : Vector2):
	var scan = get_start_scan_tile_for_fall_points(tile as Vector2i)
	if scan == null: return null
	
	var tile_scan = scan as Vector2i
	var fall_tile = null
	
	for i in range(MAX_TIME_FALL_SCAN_DEPTH): # if tile isnt empty, it is the fall tile, else go to tile_scan.y + 1
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile_scan.x, tile_scan.y + 1)) != CELL_IS_EMPTY:
			fall_tile = tile_scan
			break
		tile_scan.y += 1
	
	return fall_tile

func tile_above_exists(tile : Vector2i):
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x, tile.y - 1)) == CELL_IS_EMPTY:
		return false # if empty, return false
	return true
