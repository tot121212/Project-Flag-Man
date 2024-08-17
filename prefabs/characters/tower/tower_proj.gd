extends Node2D

func _on_lifespan_timeout():
	queue_free()
