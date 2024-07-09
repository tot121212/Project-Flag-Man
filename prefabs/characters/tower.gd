extends CharacterBody2D

@onready var proj_cooldown = %proj_cooldown
@export var proj_scene : PackedScene

func _ready():
	proj_cooldown.timeout.connect(_on_proj_cooldown_timeout)
	proj_cooldown.start()

func _on_proj_cooldown_timeout():
	var new_proj = proj_scene.instantiate()
	add_child(new_proj)
