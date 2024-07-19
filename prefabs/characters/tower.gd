extends CharacterBody2D

@onready var proj_cooldown = %proj_cooldown
@export var proj_scene : PackedScene
@export var debug_infinite_proj : bool = false

func _ready():
	proj_cooldown.timeout.connect(_on_proj_cooldown_timeout)
	proj_cooldown.one_shot = true
	if debug_infinite_proj == true:
		proj_cooldown.one_shot = false
		proj_cooldown.start()

func _on_proj_cooldown_timeout():
	var new_proj = proj_scene.instantiate()
	add_sibling(new_proj)
	new_proj.position = self.position + Vector2(-7, 5)
