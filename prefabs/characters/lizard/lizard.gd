extends CharacterBody2D
class_name EnemyLizard

signal change_orientation
signal not_surface_front_down
signal surface_front

@export var sprite : Sprite2D
@export var orientation_handler : Node2D
@export var detection_raycaster : Node
@export var stats_component : Node2D
@export var aggro_state_machine : StateMachine
@export var movement_attack_state_machine : StateMachine
@export var velocity_component : Node2D
@export var navigation_agent : NavigationAgent2D

@export var object_detect_raycasts : Node2D
var raycasts_cooldown_timer : Timer

var direction : Vector2 = Vector2.ZERO # direction is trying to go

func _ready():
	create_raycasts_cooldown_timer()

func _physics_process(delta):
	velocity_component.apply_friction(delta)
	move_and_slide()

func create_raycasts_cooldown_timer():
	raycasts_cooldown_timer = Timer.new()
	add_child(raycasts_cooldown_timer)
	raycasts_cooldown_timer.timeout.connect(_on_raycasts_cooldown_timer_timeout)
	raycasts_cooldown_timer.start(0.1)

func _on_raycasts_cooldown_timer_timeout():
	for node in object_detect_raycasts.get_children():
		if node is RayCast2D:
			var raycast : RayCast2D = node
			if raycast.name == "FrontDown":
				if not raycast.is_colliding():
					not_surface_front_down.emit(raycast.target_position)
			if raycast.name == "Front":
				if raycast.is_colliding():
					surface_front.emit(raycast.get_collision_point())
