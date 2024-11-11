extends Node
class_name ProjectileContainer
# works hand in hand with the orphanprojectilecontainer to keep track of projectiles in an orderly way

var new_parent : Node

func _ready():
	new_parent = get_tree().get_first_node_in_group("OrphanProjectileContainer")
	if not new_parent:
		print("No OrphanProjectileContainer found in SceneTree")

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()

func on_predelete() -> void:
	var children = get_children()
	if children:
		for child in children:
			child.reparent(new_parent)
