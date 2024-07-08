extends Sprite2D

@export var speed := 2
@export var damage := 1

func _physics_process(delta):
	global_position += Vector2(speed + delta, 0)

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
