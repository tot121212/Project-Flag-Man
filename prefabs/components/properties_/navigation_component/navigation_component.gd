extends Node2D
class_name NavigationComponent

var synced = false

@export var root : Node2D
@export var navigation_agent : NavigationAgent2D
@onready var default_rid = get_world_2d().get_navigation_map()

var closest_point : Vector2

var draw_debug_circle : bool = true
var circle_radius : float = 10.0
var circle_color : Color = Color(1, 0, 0)

func _ready():
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	synced = true
	print("%s: NavigationComponent: Synced" % root.name)

func set_target_position_safely(target_pos : Vector2, origin : Vector2 = root.global_position): # sets target to closest point that is within the default rid navigation map
	if synced:
		# find navigation tile that has (matching x, closest y) to target position
		closest_point = NavigationServer2D.map_get_closest_point(default_rid, target_pos)
		#print(root.name + " Closest Point on Navmesh: " + str(closest_point))
		if closest_point:
			if _check_path(origin, closest_point) != null:
				navigation_agent.set_target_position(closest_point)
			else:
				print("%s: NavigationComponent: Path is null" % root.name)
			#print(root.name + " Navigation Target Pos: " + str(navigation_agent.target_position))

func _check_path(origin : Vector2, destination : Vector2, nav_layers : int = 1, optimize : bool = true, rid : RID = default_rid):
	var path = NavigationServer2D.map_get_path(default_rid, origin, destination, optimize)
	if not _is_path_reachable(path):
		path = _calculate_alternate_path(origin, destination, nav_layers, optimize, rid)
		if path == null:
			return null
	if path.size() > 0: # remove first point
		path.remove_at(0)
	return path

func _is_path_reachable(path):
	var previous = root.global_position
	for current in path:
		if previous.y < current.y and abs(previous.y - current.y) > root.stats_component.max_jump_height:
			return false
		previous = current
	return true

func _calculate_alternate_path(origin : Vector2, destination : Vector2, _nav_layers : int = 1, optimize : bool = true, rid : RID = default_rid):
	var offset = Vector2(32, 0)
	var alt_1 = NavigationServer2D.map_get_path(rid, origin + offset, destination, optimize)
	var alt_2 = NavigationServer2D.map_get_path(rid, origin - offset, destination, optimize)
	if _is_path_reachable(alt_1):
		return alt_1
	elif _is_path_reachable(alt_2):
		return alt_2
	else:
		return null

func reset_target_position():
	if synced:
		set_target_position_safely(root.get_global_position())
