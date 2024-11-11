extends UIElement

var root : Node2D
@export var texture_rects : Array[TextureRect]

func _ready():
	show()
	call_deferred("_deferred")

func _deferred():
	root = Utils.get_first_player()
	root.stats_component.health_changed.connect(_on_health_changed)

func _on_health_changed(cur_health, _prev_health):
	print("Changing UI health display")
	for texture_rect in texture_rects:
		texture_rect.show()
	
	var health_diff = root.stats_component.max_health - cur_health
	
	for i in range(health_diff):
		if i < texture_rects.size():
			texture_rects[i].hide()
