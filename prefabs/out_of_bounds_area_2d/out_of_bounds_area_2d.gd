extends Area2D
class_name OutOfBoundsArea2D

@export var teleporation_point : Marker2D ## Point at which, if the player enters area, the player will be teleported to

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body : Node2D):
	if not (body is Player):
		return
	if body.velocity:
		body.velocity = Vector2(0,0)
	body.set_global_position(teleporation_point.global_position)
	#print("%s was teleported to %s" % [body, teleporation_point])
