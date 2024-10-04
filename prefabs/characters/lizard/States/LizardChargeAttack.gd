extends State

@export var root: Node2D
@export var velocity_component : VelocityComponent
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var stats_component : StatsComponent
@export var charge_attack_area_2d : Area2D
@export var animation_player : AnimationPlayer

var charge_timer : Timer # charge in direction for certain amount of time, then stop
var charge_timer_length : float = 4.0

var direction : Vector2 # just a static copy of a var just in case it changes for some reason while charging, 
						# we want the charge to be static

var charge_cooldown_timer : Timer # this timer shouldnt be ended on state_exit() 
										 # bc we need to keep track of that damage cooldown continuosly
var charge_cooldown_timer_length : float = 1.5 # seconds

func _ready():
	charge_timer = Timer.new()
	charge_timer.wait_time = charge_timer_length
	charge_timer.one_shot = true
	charge_timer.timeout.connect(_on_charge_timer_timeout)
	add_child(charge_timer)
	
	charge_cooldown_timer = Timer.new()
	charge_cooldown_timer.wait_time = charge_cooldown_timer_length
	charge_cooldown_timer.one_shot = true
	add_child(charge_cooldown_timer)

func state_enter():
	if charge_timer.is_stopped():
		charge_timer.start()
	direction = root.direction_of_next_nav_point
	root.change_orientation.emit(direction)
	animation_player.set_current_animation("charge")

func state_exit():
	if not charge_timer.is_stopped():
		charge_timer.stop()

func state_physics_update(delta):
	if charge_in_direction(delta) == false:
		return

func charge_in_direction(delta):
	if attack_if_able(): # if we attacked, transition out
		_on_charge_timer_timeout()
		return false
	
	# V - this isnt adctually what it does yet but eh - V
	# if object_detect a wall in front: play hitting wall stun animation
	if object_detect_raycasts.raycast_front.is_colliding(): 
		_on_charge_timer_timeout()
		return false
	
	#print("Delta: ", delta, " Direction: ", direction, " Max Speed: ", Vector2(stats_component.max_speed.x, 0), " Random Vector: ", Vector2(randf_range(-2, 2), 0))
	velocity_component.move(delta, direction, Vector2(stats_component.max_speed.x * 4.5, 0), Vector2(randf_range(-2,2), 0))

func attack_if_able():
	var bodies = charge_attack_area_2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player") and body.is_in_group("Player_Body"):
			if charge_cooldown_timer.is_stopped():
				# we can attack
				body.get_parent().velocity.x = root.velocity.x * 3.5
				body.get_parent().velocity.y -= abs(root.velocity.x) * 2.5
				charge_cooldown_timer.start()
				return true # return true if attack succesfully
	return false

func _on_charge_timer_timeout():
	transition.emit(self, "LizardChargeMovement")
