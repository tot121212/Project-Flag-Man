extends Node2D
class_name PlayerSpeedModifier

@export var root : Node2D
@export var velocity_component : VelocityComponent

@export var speed_timer : Timer # Timer that starts upon you not jumping and when it ends, it reduces speed back to default

# modify player speed based on amount of jumps performed consecutively
# have something trigger a timer when the player touches the ground
	# when that timer times out, decrease max speed back to base speed
# for each jump, while the timer is running, increase movement speed by 2% up to a max of 10%, this number is up for debate

@export var max_stored_jumps : int = 5
var stored_jumps : int = 0
var last_stored_jumps : int = 0
@export var modifier_upon_jumps : float = 0.1

func _ready() -> void:
	velocity_component.just_jumped.connect(_on_root_jump)
	speed_timer.timeout.connect(_on_speed_timer_timeout)

func _physics_process(delta: float) -> void:
	if root.is_on_floor():
		if speed_timer.is_stopped():
			speed_timer.start()
	elif not speed_timer.is_stopped():
		speed_timer.stop()

func _on_root_jump():
	if stored_jumps < max_stored_jumps:
		last_stored_jumps = stored_jumps
		stored_jumps += 1
		root.update_cur_max_speed()

func _on_speed_timer_timeout():
	last_stored_jumps = stored_jumps
	stored_jumps = 0
	root.update_cur_max_speed()
