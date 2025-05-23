extends Node2D

# This node constructs a navmesh for enemies, it also constructs light occluders

@export var tilemap_layers : Array[Node2D] ## array of tilemap layers

var navigation_layer_index : int = 0
var platform_layer_index : int = 1
var terrain_layer_index : int = 2
var background_layer_index : int = 3

var terrain_source_id : int = 0
var navigation_source_id : int = 1
var background_source_id : int = 2
var platform_source_id : int = background_source_id

var navigation_atlas_coords : Vector2i = Vector2i(1, 0) ## coordinate in atlas at which you have your navigation area texture. should be kept as an empty square, ideally
var navigation_atlas_empty_tile_coords : Vector2i = Vector2i(2, 0) # used for clearing out area
@export var max_recursions : int = 10 ## max amount of regions to add before stopping recursion

var cells_with_terrain : Array[Vector2i] = []
var cells_with_platforms : Array[Vector2i] = []

var navigation_region_cells : Array[Vector2i] = []
var navigation_region_floor_cells : Array[Vector2i] = []

func _ready():
	add_to_group("Tilemap")
	create_navigation_regions()

func _input(_event):
	if Input.is_action_just_pressed("regenerate_navmeshes"):
		print("Regenerating Navmeshes")
		#clear_navigation_regions()
		print("~")
		create_navigation_regions()
		print("~")
		print("Navmeshes Regenerated")

func create_navigation_regions(): # place nav tile above any tile that has an empty space above it, recursively up to max_recursions
	cells_with_terrain = tilemap_layers[terrain_layer_index].get_used_cells_by_id(terrain_source_id)
	cells_with_platforms = tilemap_layers[platform_layer_index].get_used_cells_by_id(platform_source_id)
	#print("Used Tile Cells: " + str(cells_with_terrain))
	for i in cells_with_terrain:
		create_navigation_region_above_cell_recursively(i, max_recursions)
	for i in cells_with_platforms:
		create_navigation_region_above_cell_recursively(i, max_recursions)

func cell_is_empty_of_terrain(cell):
	if cells_with_terrain.find(cell) == -1:
		return true
	else:
		return false

func create_navigation_region_above_cell_recursively(cell_pos : Vector2i, _remaining_recursions: int):
	var above_cell = Vector2i(cell_pos.x, cell_pos.y - 1) # get above cell
	if cell_is_empty_of_terrain(above_cell): # if above cell is empty
		tilemap_layers[navigation_layer_index].set_cell(above_cell, navigation_source_id, navigation_atlas_coords) # create nav region tile at above_cell
		if _remaining_recursions == max_recursions: # if recursion hasnt happened yet its the first tile, aka the floor tile
			navigation_region_floor_cells.append(above_cell) # add to floor tiles
		navigation_region_cells.append(above_cell) # append to an array of positions for future deletion if necessary
		if _remaining_recursions > 0: # recurse if remaining
			create_navigation_region_above_cell_recursively(above_cell, _remaining_recursions - 1)
	else:
		return

func clear_navigation_regions():
	for cell_pos in navigation_region_cells:
		tilemap_layers[navigation_layer_index].set_cell(cell_pos, navigation_source_id, Vector2i(2, 0) ) # set to empty tile
