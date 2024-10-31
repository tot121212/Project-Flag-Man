extends Menu

var root : Node2D
@export var texture_rects : Array[TextureRect]

func _ready():
	call_deferred("_deferred")

func _deferred():
	root = Utils.get_first_player()
	root.stats_component.health_changed.connect(_on_health_changed)

func _on_health_changed(_health):
	print("Changing ui health display")
	for texture_rect in texture_rects:
		texture_rect.visible = true
	
	var health_diff = root.stats_component.max_health - root.stats_component.cur_health
	
	for i in range(health_diff):
		if i < texture_rects.size():
			texture_rects[i].visible = false
