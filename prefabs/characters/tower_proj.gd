extends Sprite2D

func _on_lifespan_timeout():
	queue_free()
