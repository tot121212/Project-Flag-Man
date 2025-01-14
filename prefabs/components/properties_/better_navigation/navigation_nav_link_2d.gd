extends Node2D
class_name NavigationNavLink2D

@onready var area_2d: Area2D = $Area2D

var navigation_links: Array[NavigationLink2D]

var queue: Array[Node2D]

func _ready() -> void:
	for child in get_children():
		if child is NavigationLink2D:
			navigation_links.append(child)

func _physics_process(delta: float) -> void:
	for b in area_2d.get_overlapping_bodies():
		_exec(b)

func _exec(body: Node2D):
	pass
