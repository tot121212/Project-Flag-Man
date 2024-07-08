extends CharacterBody2D
@onready var timer = %proj_cooldown

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	timer.timeout.connect(_on_proj_cooldown_timeout)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


func _on_proj_cooldown_timeout():
	var proj_scene = preload("res://prefabs/characters/tower_proj.tscn")
	var new_proj = proj_scene.instantiate()
	add_child(new_proj)
