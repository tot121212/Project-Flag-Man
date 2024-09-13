extends CharacterBody2D
class_name ProjPlayerFlag

signal change_orientation
signal was_queue_freed

@export var projectile_component : ProjectileComponent
@export var animation_player : AnimationPlayer

func _ready():
	print("projectile spawned")
	projectile_component.proj_delete_self.connect(_on_delete_self)
	animation_player.animation_finished.connect(free_if_correct_anim)

func _physics_process(_delta):
	if move_and_slide():
		_on_delete_self()

func _on_delete_self():
	# play anim of fading out
	animation_player.play("fade_sprite_out")
	self.set_process(false)
	self.set_physics_process(false)
	await animation_player.animation_finished

func free_if_correct_anim(anim_name : StringName):
	if anim_name == "fade_sprite_out":
		was_queue_freed.emit(self.get_path())
		queue_free()
