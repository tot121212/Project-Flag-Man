extends TileMap

@export var used_layer : int = 0 ## which layer to utilize from tilemap
@export var max_recursions : int = 5 ## max amount of regions to add before stopping recursion

var used_cells : Array[Vector2i]
var to_local_cell_locations : Array[Vector2] = []
var to_global_cell_locations : Array[Vector2] = []
var cell_size : Vector2i # get tile size for tile set
var navigation_polygon : PackedVector2Array # nav polygon based upon cell size
var nav_regions : Dictionary = {} # dict to track nav regions

func ready():
	cell_size = tile_set.get_tile_size()
	navigation_polygon = get_navigation_polygon()
	used_cells = get_used_cells(used_layer) # append cell locations to array for easy access
	for cell in used_cells:
		var cell_to_local = map_to_local(cell)
		to_local_cell_locations.append(cell_to_local)
		to_global_cell_locations.append(to_global(cell_to_local))
	create_or_update_navigation_regions()

func create_or_update_navigation_regions(): # construct navigationregion2d above each cell
	for i in range(to_local_cell_locations.size()):
		var cell_local_position = to_local_cell_locations[i]
		var cell_global_position = to_global_cell_locations[i]
		if is_empty_above(cell_local_position):
			#var above_cell_global_position = Vector2(cell_global_position.x, cell_global_position.y + float(cell_size.y))
			create_or_update_navigation_region(cell_global_position, max_recursions)

func create_or_update_navigation_region(pos: Vector2, _remaining_recursions: int):
	var nav_region = null
	for existing_region in nav_regions.keys():
		if nav_regions[nav_region] == pos:
			nav_region = existing_region
			break
	
	if not nav_region:
		# Create new NavigationRegion2D if not existing
		nav_region = NavigationRegion2D.new()
		add_child(nav_region)
		nav_regions[nav_region] = pos
		
	nav_region.position = pos
	
func is_empty_above(cell_local_position : Vector2i): # is cell available to be navigated upon, i.e. is there space above it
	var cell_above = Vector2(cell_local_position.x, cell_local_position.y - 1)
	if get_cell_source_id(used_layer, cell_above) == -1:
		return true
	return false

func get_navigation_polygon() -> PackedVector2Array:
	# navigation polygon based on cell size
	var points = PackedVector2Array()
	points.append(Vector2.ZERO)
	points.append(Vector2(cell_size.x, 0))
	points.append(Vector2(cell_size.x, cell_size.y))
	points.append(Vector2(0, cell_size.y))
	return points
