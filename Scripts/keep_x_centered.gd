extends Control
class_name KeepXCentered

@onready var center = position.x + size.x / 2

func _notification(what) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		pivot_offset = size / 2
		position.x = center - size.x / 2
