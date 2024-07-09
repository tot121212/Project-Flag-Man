extends ParallaxLayer

@onready var sky_movement_timer = $sky_movement_timer

func _ready():
	sky_movement_timer.timeout.connect(_on_sky_movement_timer_timeout)
	sky_movement_timer.start()

func _on_sky_movement_timer_timeout():
	motion_offset.x += 1
