extends Area2D
#class_name SoftCollisionsArea2D

var soft_collision_cooldown_timer : Timer
@export var root : Node2D # Body with which is going to be moved if area detects other bodies
@export var velocity_component : VelocityComponent

var should_check_collisions

func _ready():
	soft_collision_cooldown_timer = get_node("SoftCollisionCooldownTimer")
	soft_collision_cooldown_timer.timeout.connect(_on_soft_collision_cooldown_timer_timeout)

func _physics_process(delta: float) -> void:
	if should_check_collisions:
		check_and_apply_collision_movement(delta)

func check_and_apply_collision_movement(delta: float) -> void:
	var overlapping_bodies : Array[Node2D] = get_overlapping_bodies()
	if !overlapping_bodies.is_empty():
		var closest_body : Node2D
		for body in overlapping_bodies:
			if not closest_body or root.global_position.distance_to(body.global_position) < root.global_position.distance_to(closest_body.global_position):
				closest_body = body
		if closest_body:
			var dir_to = root.global_position.direction_to(closest_body.global_position)
			velocity_component.move(delta, Vector2(-dir_to.x,-dir_to.y), Vector2(16,16))
	should_check_collisions = false


func _on_soft_collision_cooldown_timer_timeout():
	should_check_collisions = true
