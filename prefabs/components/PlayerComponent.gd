extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const TWO_DECIMALS: float = 0.01 # var for 2 decimal points in the snapped function

@onready var animation_player = $AnimationPlayer
@onready var viscii_jump = $SFX/VisciiJump
@onready var viscii_bounce2 = $SFX/VisciiBounce2

func _ready():
	animation_player.play("idle")

@export var jump_velocity: float = -350.0
@export var min_speed: float = 30.0
@export var max_speed: float = 200.0
@export var x_acceleration: float = 1.0

var landing: bool = false

func _physics_process(delta):
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	if not is_on_floor(): # gravity
		velocity.y += gravity * delta
		if Input.is_action_pressed("down"):
			velocity.y = move_toward(velocity.y, gravity * 2, gravity * delta * 2)
	else: # we know we are on the floor
		if landing == true:
			viscii_bounce2.play()
			landing = false
		if direction.y < 0: # if input up, then jump
			velocity.y = jump_velocity
			viscii_jump.play()
			landing = true
	
	if direction.x != 0:
		x_acceleration *= 1.1
		x_acceleration = snapped(x_acceleration, TWO_DECIMALS)
		velocity.x = move_toward(velocity.x, max_speed, snappedf(direction.x * min_speed * x_acceleration, TWO_DECIMALS))
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
	else: 
		x_acceleration = 1.0 # reset acceleration
		velocity.x = move_toward(velocity.x, 0, max_speed*2.5 * delta)
	
	move_and_slide()
