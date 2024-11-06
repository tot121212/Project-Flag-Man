extends Enemy
class_name EnemyLizard

signal change_orientation

@export var sprite : Sprite2D
@export var orientation_handler : Node2D
@export var detection_raycaster : Node
@export var stats_component : Node2D
@export var state_machine_parent : StateMachineParent
@export var aggro_state_machine : StateMachine
@export var movement_attack_state_machine : StateMachine
@export var velocity_component : Node2D
@export var navigation_agent : NavigationAgent2D
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var animation_tree : AnimationTree
@export var animation_player : AnimationPlayer

@export var target_group : String = "Player"

var is_jumping : bool = false
var direction_of_next_nav_point : Vector2 = Vector2.ZERO # direction of next point of navigation agent

var is_idling : bool = true
var is_attacking : bool = false
var is_charging : bool = false
var is_spitting : bool = false
var is_blinking : bool = false
var is_dying : bool = false

func _ready():
	stats_component.health_changed.connect(_on_health_changed)
	if !animation_player.animation_changed.is_connected(_on_animation_finished):
		animation_player.animation_changed.connect(_on_animation_finished)

func _physics_process(delta):
	if not is_jumping:
		velocity_component.apply_friction(delta)
	else:
		velocity_component.apply_friction(delta, 0.8)
		velocity_component.apply_jump(delta)
	move_and_slide()
	
func _on_health_changed(new_health):
	animation_tree["parameters/conditions/is_blinking"] = true
	if new_health <= 0:
		_on_death()

func _on_animation_finished(old_anim_name : StringName, _anim_name : StringName):
	if old_anim_name == "blink":
		animation_tree["parameters/conditions/is_blinking"] = false
	
	if old_anim_name == "death":
		animation_tree["parameters/conditions/is_dying"] = false # just for accuracy sake
		queue_free()

func _on_death():
	animation_tree["parameters/conditions/is_dying"] = true
	state_machine_parent.set_process(false)
	state_machine_parent.set_physics_process(false)
