extends Node2D

signal is_colliding_with_target(raycast, target)

@export var detection_area: Area2D ## area2d with which to detect physics bodies
@export var collide_with_bodies: bool = true ## does raycast collide with bodies
@export var collide_with_areas: bool = false ## does raycast collide with areas
@export var collision_layers: Array[int] = [2] ## layers on which the raycasts should detect visibility with
@export var raycast_lifespan_in_seconds: float = 0.05
@export var delete_raycasts_instantly: bool = false ## for testing
@export var raycast_for_tilemaps: bool = true ## simply to not send unnecesary raycasts at tilemaps and such

@onready var detection_targets: Array[Node2D] = [] # array to store all viable node2d's inside of the detection_area

func _ready():
	
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
	else:
		push_error("detection_area not set on raycaster")

func _on_body_entered(body: Node2D) -> void:
	detection_targets.append(body)
	#print(body, "entered")

func _on_body_exited(body: Node2D) -> void:
	detection_targets.erase(body)
	#print(body, "exited")
	
func _physics_process(_delta):
	for target in detection_targets:
		if target is TileMap and raycast_for_tilemaps:
			continue
		send_raycast(target)
		
func send_raycast(target: Node2D) -> void:
	var raycast = RayCast2D.new()
	if raycast:
		add_child(raycast)
		
		raycast.enabled = true
		raycast.visible = true
		
		raycast.set_collide_with_areas(collide_with_areas)
		raycast.set_collide_with_bodies(collide_with_bodies)
		
		raycast.collision_mask = 0 # clear mask
		for layer in collision_layers:
			raycast.set_collision_mask_value(layer, true)
		
		raycast.global_position = detection_area.global_position
		raycast.target_position = raycast.to_local(target.global_position)
		
		#print(self.name + "Position is: " + str(raycast.global_position))
		#print(target.name + "Target Position is: " + str(raycast.target_position))
		
		raycast.force_raycast_update()
		
		# send a signal out with the target as a parameter, if the target is colliding with the raycast
		# if raycast is colliding with target
		if raycast.get_collider() == target:
			#print(str(raycast.get_collider().get_parent().name) + " == " + str(target.name))
			#send signal that raycaster is colliding with target
			is_colliding_with_target.emit(raycast, target)
		
		if delete_raycasts_instantly:
			raycast.queue_free()
		else:
			# make timer to delete the raycast after lifespan
			var timer = Timer.new()
			if timer:
				raycast.add_child(timer)
				timer.one_shot = true
				timer.timeout.connect(_on_timeout_free_raycast.bind(raycast))
				timer.start(raycast_lifespan_in_seconds)

func _on_timeout_free_raycast(raycast):
	raycast.queue_free()
	
