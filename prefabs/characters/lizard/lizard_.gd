extends Enemy
class_name EnemyLizard

signal change_orientation

@export var sprite : Sprite2D
@export var orientation_handler : Node2D
@export var detection_raycaster : Node
@export var stats_component : StatsComponent
@export var state_machine_parent : StateMachineParent
@export var aggro_state_machine : StateMachine
@export var movement_attack_state_machine : StateMachine
@export var velocity_component : Node2D
@export var navigation_agent : NavigationAgent2D
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var animation_tree : AnimationTree

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
	animation_tree.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if not is_jumping:
		velocity_component.apply_friction(delta)
	else:
		velocity_component.apply_friction(delta, 0.8)
		velocity_component.apply_jump(delta)
	
		move_and_slide()

func _on_health_changed(new_health : int, prev_health : int):
	print("%s: On health change" % self.name)
	if new_health <= 0:
		_on_death()
	elif prev_health > new_health:
		animation_tree.set("parameters/conditions/is_blinking", true)

func _on_death():
	print("%s: On death" % self.name)
	animation_tree.set("parameters/conditions/is_dying", true)
	#self.set_process(false)
	#self.set_physics_process(false)

func _on_animation_finished(anim_name : String):
	match anim_name:
		"blink":
			_after_blink()
		"death":
			_after_death()

func _after_blink():
	print("%s: After blink" % self.name)
	animation_tree.set("parameters/conditions/is_blinking", false)

func _after_death():
	print("%s: After death" % self.name)
	animation_tree.set("parameters/conditions/is_dying", false) # just for accuracy sake
	if !is_queued_for_deletion():
		queue_free()
		print("%s is queued for deletion" % self.name)
