extends Node2D
class_name ProjectileComponent

signal proj_delete_self

@export var root: Node2D ## projectile root
@export var velocity_component : VelocityComponent
@export var stats_component : StatsComponent

@export var direction : Vector2 ## direction of projectile
@export var damage : int = 1 ## damage of projectile

@export_category("Lifespan")
## Should projectile delete itself after x amount of time existing
@export var use_lifespan : bool = true
@onready var lifespan_timer : Timer = Timer.new()
@export var lifespan : float = 1.0 ## Lifespan in seconds of projectile.

@export_category("Offscreen Deletion")
## Should projectile delete itself after being off-screen for x amount of time
@export var use_off_screen_deletion_timer : bool = true
@onready var off_screen_deletion_timer : Timer = Timer.new()
@export var off_screen_deletion_timer_lifespan : float = 1.0 ## Lifespan of a timer for deleting projectiles that go offscreen.
@export var visible_on_screen_notifier : VisibleOnScreenNotifier2D ## Needed for determining whether its on-screen or not

@export_category("Seeking")
@export var is_seeking : bool = false ## if projectile is seeking
var seek_position : Vector2 = Vector2.ZERO # global position at which to seek to

func _ready():
	#print("Projectile Spawned")
	if use_lifespan and lifespan > 0:
		lifespan_timer.one_shot = true
		lifespan_timer.wait_time = lifespan
		lifespan_timer.timeout.connect(_on_lifespan_timer_timeout)
		lifespan_timer.start()
	if use_off_screen_deletion_timer and off_screen_deletion_timer_lifespan > 0:
		off_screen_deletion_timer.wait_time = off_screen_deletion_timer_lifespan
		off_screen_deletion_timer.timeout.connect(_on_is_on_screen_timer_timeout)
		
		visible_on_screen_notifier.screen_entered.connect(_is_visible_on_screen)
		visible_on_screen_notifier.screen_exited.connect(_is_not_visible_on_screen)
	if not direction:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))

func _is_visible_on_screen():
	if not off_screen_deletion_timer.is_stopped():
		off_screen_deletion_timer.stop()

func _is_not_visible_on_screen():
	if off_screen_deletion_timer.is_stopped():
		off_screen_deletion_timer.start()

func _physics_process(delta):
	if is_seeking:
		direction = root.direction_to(seek_position)
	
	if direction != Vector2.ZERO:
		velocity_component.move(delta, direction, stats_component.max_speed)
		
	root.change_orientation.emit(direction)

func _on_lifespan_timer_timeout():
	#print("Projectile Lifespan Reached")
	if lifespan > 0:
		proj_delete_self.emit()

func _on_is_on_screen_timer_timeout():
	#print("Projectile Cleared Offscreen")
	if off_screen_deletion_timer_lifespan > 0:
		proj_delete_self.emit()
