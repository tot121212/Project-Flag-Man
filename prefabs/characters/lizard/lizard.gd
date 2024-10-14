extends CharacterBody2D
class_name EnemyLizard

signal change_orientation

@export var sprite : Sprite2D
@export var orientation_handler : Node2D
@export var detection_raycaster : Node
@export var stats_component : Node2D
@export var aggro_state_machine : StateMachine
@export var movement_attack_state_machine : StateMachine
@export var velocity_component : Node2D
@export var navigation_agent : NavigationAgent2D
@export var object_detect_raycasts : ObjectDetectRaycasts

@export var target_group : String = "PlayerBody"

var is_jumping : bool = false
var direction_of_next_nav_point : Vector2 = Vector2.ZERO # direction of next point of navigation agent

func _ready():
	SignalBus.projectile_collision.connect(_on_projectile_collision)
	stats_component.health_changed.connect(_on_health_changed)

func _physics_process(delta):
	if not is_jumping:
		velocity_component.apply_friction(delta)
	else:
		velocity_component.apply_friction(delta, 0.8)
		velocity_component.apply_jump(delta)
	move_and_slide()

func _on_projectile_collision(collider, self_match, damage):
	if not self_match == self:
		return
	if damage:
		stats_component.take_damage(damage)
	
func _on_health_changed(new_health):
	if new_health <= 0:
		_on_death()

func _on_death():
	queue_free()
