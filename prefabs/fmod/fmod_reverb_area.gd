extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	#print("Body entered: %s" % body.name)
	if body.is_in_group("Player") and GameState.fmod_cave_reverb_event:
		#print("Fmod: start cave reverb")
		GameState.fmod_cave_reverb_event.start()

func _on_body_exited(body):
	if body.is_in_group("Player") and GameState.fmod_cave_reverb_event:
		#print("Fmod: stop cave reverb")
		GameState.fmod_cave_reverb_event.stop(0)
