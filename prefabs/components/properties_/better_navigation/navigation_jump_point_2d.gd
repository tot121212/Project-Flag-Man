extends NavigationNavLink2D
class_name NavigationJumpPoint2D

@onready var path: Path2D = $Path2D

var Xspeed: float

signal start_nav_jump
signal nav_link_reached(Node2D, Dictionary)

func _exec(body: Node2D):
	if queue.has(body) and body.has_method("_on_start_nav_jump"):
		var jumpHeight = 0
		
		for point in path.curve.get_baked_points():
			if point.y < jumpHeight:
				jumpHeight = point.y
		
		if body is Node2D:
			body._on_start_nav_jump()
			body._jump(_calculate_jump_height(jumpHeight))
		
		queue.erase(body)

func _calculate_jump_height(pixel_height: float) -> float:
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	return -sqrt(2 * gravity * abs(pixel_height))

func _on_navigation_agent_2d_link_reached(_self, details: Dictionary) -> void:
	if details.owner.get_parent() is NavigationNavLink2D:
		var nav_link: NavigationNavLink2D = details.owner.get_parent()
		
		if !nav_link.queue.has(self):
			print ("Entered navlink" + str(nav_link))
			nav_link.queue.append(self)
