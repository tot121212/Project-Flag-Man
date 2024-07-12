extends Node

@export var detection_area: Area2D 
@export var raycast_length: float = 500.0
@export var collide_with_bodies: bool = true
@export var collide_with_areas: bool = false
@export var collision_layers: Array[int] = [2]

var detection_target: Array[PhysicsBody2D] = []

func _ready():
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
	else:
		push_error("detection_area not set on raycaster")

func _on_body_entered(body: PhysicsBody2D) -> void:
	detection_target.append(body)

func _on_body_exited(body: PhysicsBody2D) -> void:
	detection_target.erase(body)
	
func _physics_process(delta):
	for target in detection_target:
		send_raycast(target)

func send_raycast(target: PhysicsBody2D) -> void:
	var raycast = RayCast2D.new()
	if detection_area and raycast:
		detection_area.add_child(raycast)
		
		raycast.enabled = true
		raycast.visible = true
		raycast.set_collide_with_areas(collide_with_areas)
		raycast.set_collide_with_bodies(collide_with_bodies)
		
		raycast.set_collision_mask_value(1, false) # disable the default
		for layer in collision_layers:
			raycast.set_collision_mask_value(layer, true)
		
		raycast.position = detection_area.global_position
		
		var direction : Vector2 = (target.global_position - detection_area.global_position).normalized()
		
		raycast.set_target_position(direction * raycast_length)
		
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			print("Raycast hit a ", collider.name)
		
		# TODO: Check the _draw method to test raycast, seems like its working but i cant see the ray
		
		raycast.queue_free()
	else:
		push_error("detection_area not set on raycaster")
