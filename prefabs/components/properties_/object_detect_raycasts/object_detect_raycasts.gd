extends Node2D
class_name ObjectDetectRaycasts

var raycasts_cooldown_timer : Timer

@export var raycast_front : RayCast2D
@export var raycast_front_down : RayCast2D

var is_surface_front : bool = false
var is_surface_front_down : bool = true

func _ready():
	create_object_detect_raycasts_cooldown_timer()

func create_object_detect_raycasts_cooldown_timer():
	raycasts_cooldown_timer = Timer.new()
	add_child(raycasts_cooldown_timer)
	raycasts_cooldown_timer.timeout.connect(_on_raycasts_cooldown_timer_timeout)
	_on_raycasts_cooldown_timer_timeout()
	raycasts_cooldown_timer.start(0.1)

func _on_raycasts_cooldown_timer_timeout():
	if raycast_front.is_colliding():
		is_surface_front = true
	else:
		is_surface_front = false
	
	if raycast_front_down.is_colliding():
		is_surface_front_down = true
	else: 
		is_surface_front_down = false
