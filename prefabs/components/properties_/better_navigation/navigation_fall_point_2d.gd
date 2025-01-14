extends NavigationNavLink2D
class_name NavigationFallPoint2D

signal start_nav_fall

func _exec(body: Node2D):
	if queue.has(body):
		if body is Enemy:
			body._fall_through_oneway_platform()
			body.in_navLink = true
		
		queue.erase(body)
