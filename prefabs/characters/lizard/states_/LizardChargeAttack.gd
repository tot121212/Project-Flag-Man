extends State

@export var root: Node2D
@export var velocity_component : VelocityComponent
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var stats_component : StatsComponent
@export var charge_attack_area_2d : Area2D
@export var animation_player : AnimationPlayer
@export var orientation_handler : OrientationHandler2DSimplified

@export var charge_timer : Timer # charge in direction for certain amount of time, then stop
@export var charge_cooldown_timer : Timer # this timer shouldnt be ended on state_exit() 
								  # bc we need to keep track of the cooldown continuosly

var direction : Vector2 # just a static copy of a var just in case it changes for some reason while charging, 
						# we want the charge to be static

var stun_time : float = 0.5 # seconds

func state_enter():
	if not charge_timer.timeout.is_connected(_on_charge_timer_timeout):
		charge_timer.timeout.connect(_on_charge_timer_timeout)
		
	if charge_timer.is_stopped():
		charge_timer.start()
	
	if root.direction_of_next_nav_point.x != 0:
		direction = root.direction_of_next_nav_point
	else:
		direction = Vector2.RIGHT
	
	root.change_orientation.emit(direction)
	orientation_handler.ignore_orientation_changes = true
	
	animation_player.set_current_animation("charge")

func state_exit():
	orientation_handler.ignore_orientation_changes = false
	
	if not charge_timer.is_stopped():
		charge_timer.stop()
		
	if charge_timer.timeout.is_connected(_on_charge_timer_timeout):
		charge_timer.timeout.disconnect(_on_charge_timer_timeout)
		
	charge_cooldown_timer.start()

func state_physics_update(delta):
	if not has_been_stunned:
		charge_in_direction(delta)

var has_been_stunned = false
func charge_in_direction(delta):
	if attack_if_able(): # if we attacked, transition out
		_on_charge_timer_timeout()

	if object_detect_raycasts.raycast_front.is_colliding():
		has_been_stunned = true
		call_deferred("_on_charge_timer_timeout_delayed")
	
	#print("Delta: ", delta, " Direction: ", direction, " Max Speed: ", Vector2(stats_component.max_speed.x, 0), " Random Vector: ", Vector2(randf_range(-2, 2), 0))
	velocity_component.move(delta, direction, Vector2(stats_component.max_speed.x * 4.5, 0), Vector2(randf_range(-2,2), 0))

func attack_if_able():
	var bodies = charge_attack_area_2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			if charge_cooldown_timer.is_stopped():
				body.velocity.x = root.velocity.x * 3.5
				body.velocity.y -= abs(root.velocity.x) * 2.5
				charge_cooldown_timer.start()
				body.stats_component.take_damage(1)
				return true
	return false

func _on_charge_timer_timeout():
	transition.emit(self, "LizardChargeMovement")

func _on_charge_timer_timeout_delayed():
	if has_been_stunned == true:
		has_been_stunned = false
	
	# TODO: play hitting wall stun animation
	# animation_player.set_current_animation("stunned")
	await get_tree().create_timer(stun_time).timeout
	
	_on_charge_timer_timeout()
