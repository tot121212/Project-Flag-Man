extends TileMap
class_name TileMapPathFind

@export var show_debug_graph : bool = true
var jump_distance : int = 5
var jump_height : int = 4
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

func get_point_info_at_position(pos : Vector2) -> PointInfo:
	var new_info_point : PointInfo = PointInfo.new(-10000, pos) # create new pointinfo with pos
	new_info_point.is_position_point = true # mark as position point
	var tile = local_to_map(pos) # get tile position
	
	#if tile below
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x, tile.y + 1)) != CELL_IS_EMPTY:
		# if tile exists on sides
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x - 1, tile.y)) != CELL_IS_EMPTY:
			new_info_point.is_left_wall = true
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x + 1, tile.y)) != CELL_IS_EMPTY:
			new_info_point.is_right_wall = true 
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x - 1, tile.y + 1)) != CELL_IS_EMPTY:
			new_info_point.is_left_edge = true
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x + 1, tile.y + 1)) != CELL_IS_EMPTY:
			new_info_point.is_right_edge = true
	return new_info_point

func reverse_stack(stack: Array) -> Array:
	var reversed_stack: Array = []
	while stack.size() > 0:
		reversed_stack.append(stack.pop_back())
	return reversed_stack

func get_platform_2d_path(start_pos : Vector2, end_pos : Vector2):
	var path_stack : Array[PointInfo] = []
	var id_path = _astar_graph.get_id_path(_astar_graph.get_closest_point(start_pos), _astar_graph.get_closest_point(end_pos))
	if id_path.size <= 0: return path_stack
	var start_point = get_point_info_at_position(start_pos)
	var end_point = get_point_info_at_position(end_pos)
	var num_points_in_path = id_path.size()
	
	for i in range(num_points_in_path):
		var cur_point = get_info_point_by_point_id(id_path[i])
		path_stack.push_back(cur_point)

func get_info_point_by_point_id(point_id : int) -> PointInfo:
	for p in _point_info_list:
		if p.point_id == point_id:
			return p
	return null

func draw_debug_line(to : Vector2, from : Vector2, color : Color):
	if show_debug_graph:
		draw_line(to, from, color)

func add_graph_points():
	for tile in _used_tiles:
		add_left_edge_point(tile)
		add_right_edge_point(tile)
		add_left_wall_point(tile)
		add_right_wall_point(tile)
		add_fall_point(tile)

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

func _draw():
	if show_debug_graph:
		connect_points()

func connect_points(): # for each point, connect to viable neighbors
	for p1 in _point_info_list:
		connect_horizontal_points(p1)
		connect_jump_points(p1)
		connect_fall_point(p1)

func connect_fall_point(p1 : PointInfo):
	if p1.is_left_edge or p1.is_right_edge:
		var local_pos = local_to_map(p1.position)
		local_pos.y += 1
		
		var fall_point = find_fall_point(local_pos)
		if fall_point != null:
			var point_info : PointInfo = get_point_info(fall_point)
			var p2_map : Vector2 = local_to_map(p1.position)
			var p1_map : Vector2 = local_to_map(point_info.position)
			
			if p1_map.distance_to(p2_map) <= jump_height:
				_astar_graph.connect_points(p1.point_id, point_info.point_id)
				draw_debug_line(p1.position, point_info.position, Color(0,1,0,1)) # green if within jump distance
			else:
				_astar_graph.connect_points(p1.point_id, point_info.point_id, false)
				draw_debug_line(p1.position, point_info.position, Color(1,1,0,1))

func connect_jump_points(p1: PointInfo):
	for p2 in _point_info_list:
		connect_horizontal_platform_jumps(p1, p2)
		connect_diagonal_jump_right_edge_to_left_edge(p1, p2)
		connect_diagonal_jump_left_edge_to_right_edge(p1, p2)

func connect_diagonal_jump_right_edge_to_left_edge(p1 : PointInfo, p2 : PointInfo):
	if p1.is_right_edge:
		var p1_map : Vector2 = local_to_map(p1.position)
		var p2_map : Vector2 = local_to_map(p2.position)
		
		# if p2 is left edge
		# and p2 is to right of p1
		# and p2 is below p1
		# and distance between is within jump reach
		if (p2.is_left_edge 
		and p2.position.x > p1.position.x 
		and p2.position.y > p1.position.y 
		and p2_map.distance_to(p1_map) <= jump_distance): 
			_astar_graph.connect_points(p1.point_id, p2.point_id)
			draw_debug_line(p1.position, p2.position, Color(1,1,0,1))

func connect_diagonal_jump_left_edge_to_right_edge(p1 : PointInfo, p2 : PointInfo):
	if p1.is_left_edge:
		var p1_map : Vector2 = local_to_map(p1.position)
		var p2_map : Vector2 = local_to_map(p2.position)
		
		# if p2 is left edge
		# and p2 is to right of p1
		# and p2 is below p1
		# and distance between is within jump reach
		if (p2.is_right_edge 
		and p2.position.x < p1.position.x 
		and p2.position.y > p1.position.y 
		and p2_map.distance_to(p1_map) <= jump_distance): 
			_astar_graph.connect_points(p1.point_id, p2.point_id)
			draw_debug_line(p1.position, p2.position, Color(0,1,0,1))

func connect_horizontal_platform_jumps(p1 : PointInfo, p2 : PointInfo):
	if p1.point_id == p2.point_id: return
	
	if p2.position.y == p1.position.y and p1.is_right_edge and p2.is_left_edge:
		if p2.position.x > p1.position.x:
			var p2_map : Vector2 = local_to_map(p2.position)
			var p1_map : Vector2 = local_to_map(p1.position)
			
			if p2_map.distance_to(p1_map) <= jump_distance: # if distance between map pos is within jump reach
				_astar_graph.connect_points(p1.point_id, p2.point_id) # connect points
				draw_debug_line(p1.position, p2.position, Color(0,1,1,1)) # create line

func connect_horizontal_points(p1 : PointInfo):
	if p1.is_left_edge or p1.is_left_wall or p1.is_fall_tile:
		var closest : PointInfo = null
		for p2 in _point_info_list:
			if p1.point_id == p2.point_id: continue # if points are same, go to next point. self cant be connected to self, duh
			#if p2 is to the right of p1 with no y difference, and is a right edge or wall
			if (p2.is_right_edge or p2.is_right_wall or p2.is_fall_tile) and p2.position.y == p1.position.y and p2.position.x > p1.position.x:
				if closest == null: # if closesnt not initialized, initialize
					closest = PointInfo.new(p2.point_id, p2.position)
				if p2.position.x < closest.position.x: # if closer, set to closest
					closest.position = p2.position
					closest.point_id = p2.point_id
		if closest != null:
			if (horizontal_connection_can_be_made(p1.position, closest.position)):
				_astar_graph.connect_points(p1.point_id, closest.point_id)
				draw_debug_line(p1.position, closest.position, Color(0,1,0,1)) # draw lines horizontally

func horizontal_connection_can_be_made(p1 : Vector2i, p2 : Vector2i):
	var start_scan = local_to_map(p1)
	var end_scan = local_to_map(p2)
	for i in range(start_scan.x, end_scan.x):
		if get_cell_source_id(COLLISION_LAYER, Vector2i(i, start_scan.y)) != CELL_IS_EMPTY or get_cell_source_id(COLLISION_LAYER, Vector2i(i, start_scan.y + 1)) == CELL_IS_EMPTY:
			return false
	return true

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

func find_fall_point(tile : Vector2i):
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

func add_fall_point(tile : Vector2i):
	var fall_tile = find_fall_point(tile)               # find fall tile point
	if fall_tile == null: return                                   # if not found return
	var fall_tile_local : Vector2i = map_to_local(fall_tile)       # get local coords of fall tile
	var existing_point_id = tile_already_exists_in_graph(fall_tile)# check if point already added
	if existing_point_id == -1:                                    # if point doesnt exist
		var point_id = _astar_graph.get_available_point_id()       # get an id
		var point_info = PointInfo.new(point_id, fall_tile_local)  # make new pointinfo object
		point_info.is_fall_tile = true                             # flag is fall tile
		_point_info_list.append(point_info)                        # append object to list
		_astar_graph.add_point(point_id, fall_tile_local)          # add point to astar graph
		add_visual_point(fall_tile, Color(1, 0.35, 0.1, 1), 0.35)  # render visual for point
	else:
		for point_info in _point_info_list:                               
			if point_info.point_id == existing_point_id:                  # flag that existing point is
				point_info.is_fall_tile = true
				add_visual_point(fall_tile, Color("#ef7d57"), 0.30)
				break
	
func tile_above_exists(tile : Vector2i):
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x, tile.y - 1)) == CELL_IS_EMPTY:
		return false # if empty, return false
	return true
