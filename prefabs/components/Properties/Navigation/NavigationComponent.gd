extends Node2D
class_name NavigationComponent

@export var root : Node2D
@export var navigation_agent : NavigationAgent2D
@onready var default_rid = get_world_2d().get_navigation_map()
var synced = false
var closest_point : Vector2

func _ready():
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	synced = true
	print("nav component synced")

func set_target_position(target_pos : Vector2):
	if synced == true:
		# find navigation tile that has (matching x, closest y) to target position
		closest_point = NavigationServer2D.map_get_closest_point(default_rid, target_pos)
		#print(root.name + " Closest Point on Navmesh: "+str(closest_point))
		if closest_point:
			navigation_agent.set_target_position(closest_point)
			#print(root.name + " Navigation Target Pos: "+str(navigation_agent.target_position))

func reset_target_position():
	if synced == true:
		root.set_global_position(navigation_agent.get_target_position())
