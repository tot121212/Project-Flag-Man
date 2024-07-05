extends CharacterBody2D

const NORMAL_SPEED = 150
const MAX_SPEED = 200

const JUMP_VELOCITY = -350

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("idle")

@export var jump_smooth:  = 0

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else: # we know we are on the floor
		if Input.is_action_just_pressed("ui_up"): # if then jump
			velocity.y = JUMP_VELOCITY
			velocity.x += sign(velocity.x) * 100 # add a slight bit of horizontal velocity upon jump
	
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction && ( velocity.x * 1 < MAX_SPEED):
		velocity.x += direction * NORMAL_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SPEED * 0.05)
		
	if velocity.x * 1 > MAX_SPEED:
		velocity.x = MAX_SPEED
		
	move_and_slide() # velocity occurs
