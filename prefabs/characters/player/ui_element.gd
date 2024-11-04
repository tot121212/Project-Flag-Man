extends Control
class_name UIElement

func _ready():
	Utils.attach_ui_to_node.connect(_on_attach_ui_to_node)

func _on_attach_ui_to_node(node : Node2D):
	self.get_parent().call_deferred("remove_child", self)
	node.call_deferred("add_child", self); print("Attaching UIElement %s to %s" % [self.name, node])
