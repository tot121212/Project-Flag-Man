extends Node
class_name ProjectileComponent

@export var body: Node2D ## projectile root
@export var speed: Vector2 = Vector2(400.0, 0.0) ## speed of projectile
@export var direction: Vector2 = Vector2.RIGHT ## direction of projectile
@export var lifespan: float = 1.0 ## Lifespan in seconds of projectile
@export var damage: float = 1.0 ## damage of projectile

## If [color=green]lifespan_signal[/color] is true,
## the ProjectileComponent will emit a self destruct signal (proj_delete_self) for its parent to delete itself.
## [br]Else, the script will just go directly to the parent of the ProjectileComponent and delete it.
@export var lifespan_signal = true

var lifespan_timer: Timer

func _ready():
	direction = direction.normalized()
	
	lifespan_timer = Timer.new()
	lifespan_timer.autostart = true
	lifespan_timer.one_shot = true
	
	add_child(lifespan_timer)
	
	lifespan_timer.timeout.connect(_on_timer_timeout)
	lifespan_timer.start()
	
func _physics_process(delta):
	body.position += speed * delta

signal proj_delete_self
func _on_timer_timeout():
	if lifespan_signal:
		proj_delete_self.emit()
	else:
		self.get_parent().queue_free()
