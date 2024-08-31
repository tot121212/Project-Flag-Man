extends TileMap

@export var terrain_layer : int = 1
@export var navigation_layer : int = 0
@export var terrain_source_id : int = 0
@export var navigation_source_id : int = 1
@export var navigation_atlas_coords : Vector2i = Vector2i(1, 0) ## coordinate in atlas at which you have your navigation area texture. should be kept as an empty square, ideally
@export var max_recursions : int = 10 ## max amount of regions to add before stopping recursion

var used_tile_positions : Array[Vector2i]
var navigation_region_tile_positions : Array[Vector2i]
var navigation_region_floor_tile_positions : Array[Vector2i]

func _ready():
	self.add_to_group("Tilemap")
	used_tile_positions = get_used_cells_by_id(terrain_layer) # get used tiles only for layer used, which is usually terrain layer
	create_navigation_regions()

func create_navigation_regions(): # place nav tile above any tile that has an empty space above it, recursively up to max_recursions
	for i in range(used_tile_positions.size()):
		var used_tile_position : Vector2i = used_tile_positions[i]
		create_navigation_region_above_position(used_tile_position, max_recursions)

func create_navigation_region_above_position(tile_position : Vector2i, _remaining_recursions: int):
	var above_tile_position = Vector2i(tile_position.x, tile_position.y - 1)
	if get_cell_source_id(terrain_source_id, above_tile_position) == -1: # if above position on terrain layer has no cell to get id from, we know that there is no terrain there
		set_cell(navigation_layer, above_tile_position, navigation_source_id, navigation_atlas_coords) # create nav region tile at above_tile_position
		if _remaining_recursions == max_recursions: # if recursion hasnt happened yet its the first tile, aka the floor tile
			navigation_region_floor_tile_positions.append(above_tile_position) # add to floor tiles
		navigation_region_tile_positions.append(above_tile_position) # append to an array of positions for future deletion if necessary
		if _remaining_recursions > 0: # recurse if remaining
			create_navigation_region_above_position(above_tile_position, _remaining_recursions - 1)

