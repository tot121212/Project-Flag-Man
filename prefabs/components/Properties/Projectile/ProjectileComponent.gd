extends Node2D
class_name ProjectileComponent

signal proj_delete_self

@export var root: Node2D ## projectile root
@export var velocity_component : VelocityComponent
@export var orientation_handler : OrientationHandler2DSimplified
@export var stats_component : StatsComponent

@export var direction : Vector2 ## direction of projectile
@export var damage : int = 1 ## damage of projectile

@export var lifespan : float = 1.0 ## Lifespan in seconds of projectile (Set to zero for none)
@export var lifespan_signal : bool = false ## If [color=green]lifespan_signal[/color] is true, the ProjectileComponent will emit a self destruct signal (proj_delete_self) for its parent to delete itself. [br]Else, the script will just go directly to the parent of the ProjectileComponent and delete it.
@export var lifespan_timer : Timer

@export var is_seeking : bool = false ## if projectile is seeking
var seek_position : Vector2 = Vector2.ZERO # global position at which to seek to

func _ready():
	if lifespan > 0:
		lifespan_timer.wait_time = lifespan
		lifespan_timer.timeout.connect(_on_timer_timeout)
		lifespan_timer.start()

func _physics_process(delta):
	if is_seeking:
		direction = root.direction_to(seek_position)
	
	if direction != Vector2.ZERO:
		velocity_component.move(delta, direction, stats_component.max_speed)
		if direction != orientation_handler.last_direction:
			root.change_orientation.emit(direction)

func _on_timer_timeout():
	if lifespan > 0 and lifespan_signal:
		proj_delete_self.emit()
	elif lifespan > 0:
		self.get_parent().queue_free()
