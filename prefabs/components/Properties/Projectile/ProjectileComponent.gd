extends Node2D
class_name ProjectileComponent

signal proj_delete_self

@export var root: Node2D ## projectile root
@export var velocity_component : VelocityComponent
@export var orientation_handler : OrientationHandler2DSimplified
@export var stats_component : StatsComponent

@export var direction : Vector2 ## direction of projectile
@export var damage : int = 1 ## damage of projectile

@export var lifespan_timer : Timer
@export var lifespan : float = 1.0 ## Lifespan in seconds of projectile. Set to 0 to disable.
@export var lifespan_signal : bool = false ## If [color=green]lifespan_signal[/color] is true, the ProjectileComponent will emit a self destruct signal (proj_delete_self) for its parent to delete itself. [br]Else, the script will just go directly to the parent of the ProjectileComponent and delete it. This also affects the is_on_screen_timer_lifespan

@export var is_off_screen_timer : Timer
@export var is_off_screen_timer_lifespan : float = 1.0 ## Lifespan of a timer for deleting projectiles that go offscreen. Set to 0 to disable
@export var visible_on_screen_notifier : VisibleOnScreenNotifier2D

@export var is_seeking : bool = false ## if projectile is seeking
var seek_position : Vector2 = Vector2.ZERO # global position at which to seek to

func _ready():
	#print("Projectile Spawned")
	if lifespan > 0:
		lifespan_timer.wait_time = lifespan
		lifespan_timer.timeout.connect(_on_lifespan_timer_timeout)
		lifespan_timer.start()
	if is_off_screen_timer_lifespan > 0:
		is_off_screen_timer.wait_time = is_off_screen_timer_lifespan
		is_off_screen_timer.timeout.connect(_on_is_on_screen_timer_timeout)
		visible_on_screen_notifier.screen_entered.connect(_is_visible_on_screen)
		visible_on_screen_notifier.screen_exited.connect(_is_not_visible_on_screen)
		#dont start because we need to recieve is off screen signal first

func _is_visible_on_screen():
	if not is_off_screen_timer.is_stopped():
		is_off_screen_timer.stop()

func _is_not_visible_on_screen():
	if is_off_screen_timer.is_stopped():
		is_off_screen_timer.start()

func _physics_process(delta):
	if is_seeking:
		direction = root.direction_to(seek_position)
	
	if direction != Vector2.ZERO:
		velocity_component.move(delta, direction, stats_component.max_speed)
		if direction != orientation_handler.last_direction:
			root.change_orientation.emit(direction)

func _on_lifespan_timer_timeout():
	#print("Projectile Lifespan Reached")
	if lifespan > 0:
		if lifespan_signal:
			proj_delete_self.emit()
		else:
			self.get_parent().queue_free()

func _on_is_on_screen_timer_timeout():
	#print("Projectile Cleared Offscreen")
	if is_off_screen_timer_lifespan > 0:
		if lifespan_signal:
			proj_delete_self.emit()
		else:
			self.get_parent().queue_free()
