extends ParallaxLayer

func _ready():
	var sky_movement_timer = Timer.new()
	add_child(sky_movement_timer)
	sky_movement_timer.timeout.connect(_on_sky_movement_timer_timeout)
	sky_movement_timer.start(0.2)

func _on_sky_movement_timer_timeout():
	motion_offset.x += 1
