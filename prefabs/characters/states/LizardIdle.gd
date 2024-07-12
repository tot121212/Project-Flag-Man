extends State
class_name LizardIdle

@export var body: CharacterBody2D
@export var move_speed := 10.0
@export var raycast : RayCast2D

var move_direction : Vector2
var wander_time : float

func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), 0).normalized()
	wander_time = randf_range(1,3)

func Enter():
	randomize_wander()
	
func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
		
	else:
		randomize_wander()
		
func Physics_Update(delta: float):
	if body:
		body.velocity = move_direction * move_speed
	# TODO: if raycast.collide_with_bodies:
		#switch to an aggro state
