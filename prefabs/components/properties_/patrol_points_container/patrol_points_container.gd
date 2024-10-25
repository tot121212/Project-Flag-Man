extends Node
class_name PatrolPointsContainer

@export var root : Node
@export var navigation_component : NavigationComponent

@export var should_patrol_if_able = true
var should_return_to_patrol_point : bool = false

@export var patrol_points : Array[Node2D]
var cur_patrol_point : Node2D
var cur_patrol_point_index : int = 0
var amt_of_patrol_points : int = -1
var is_patrol_going_right : bool = true

func get_amt_of_patrol_points():
	amt_of_patrol_points = patrol_points.size()

func set_target_pos_to_next_patrol_point():
	get_amt_of_patrol_points()
	if amt_of_patrol_points > 0:
		cur_patrol_point_index = patrol_points.find(cur_patrol_point) # find cur patrol point
		if is_patrol_going_right:
			if cur_patrol_point_index == (amt_of_patrol_points - 1): # if we are at end of array
				is_patrol_going_right = false
				set_target_pos_to_next_patrol_point()
			else: # we are not at the end of the array
				cur_patrol_point_index += 1
				cur_patrol_point = patrol_points[cur_patrol_point_index]
				navigation_component.set_target_position_safely(cur_patrol_point.global_position)
		else:
			if cur_patrol_point_index == 0: # if we are at start of array
				is_patrol_going_right = true
				set_target_pos_to_next_patrol_point()
			else: # we are not at the end of the array
				cur_patrol_point_index -= 1
				cur_patrol_point = patrol_points[cur_patrol_point_index]
				navigation_component.set_target_position_safely(cur_patrol_point.global_position)

func set_target_pos_to_closest_patrol_point():
	var closest_point = null
	for point in patrol_points:
		if closest_point == null or root.global_position.distance_to(point.global_position) <= root.global_position.distance_to(closest_point.global_position):
			closest_point = point
	navigation_component.set_target_position_safely(closest_point.global_position)
