extends Node2D
class_name OrphanProjectileContainer
# Does nothing on its own, works with ProjectileContainer on entities and gets projectiles before said entities are deleted.

func _ready() -> void:
	self.add_to_group("OrphanProjectileContainer")
