extends State
class_name LizardCharge

@export var body: CharacterBody2D
@export var move_speed := 20.0

var target: CharacterBody2D

func Enter():
	target = get_tree().get_first_node_in_group("Player")
		
func Physics_Update(delta: float):
	var direction = target.global_position - body.global_position
	
	if direction.length() > 25:
		body.velocity - direction.normalized() * move_speed
	else:
		body.velocity = Vector2()
