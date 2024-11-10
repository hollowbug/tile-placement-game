extends Container
class_name DynamicContainer

@export_enum("Horizontal", "Vertical") var direction = "Horizontal":
	set(value):
		direction = value
		#print("DynamicContainer's direction has changed, updating.")
		_update()
@export var min_size := 0.0
@export var max_size := 1000.0
@export var tween_duration := 0.2
var _tween : Tween

func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		_update()

func _update() -> void:
	if !is_inside_tree():
		return
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var children = get_children()
	if children.size() == 0:
		_tween.tween_property(self, "custom_minimum_size", Vector2(), tween_duration)
	elif children.size() == 1:
		_tween.tween_property(self, "custom_minimum_size", children[0].size, tween_duration)
		_tween.tween_property(children[0], "position", Vector2(), tween_duration)
	else:
		var total_size = Vector2()
		
		for child in children:
			if child is Control:
				total_size += child.size
				
		if direction == "Horizontal" and total_size.x > max_size:
			_tween.tween_property(self, "custom_minimum_size:x", max_size, tween_duration)
			var gap = (( max_size
					- (children[0].size.x + children[-1].size.x) / 2 )
					/ (children.size() - 1))
			var pos = 0
			for child in children:
				if child is Control:
					_tween.tween_property(child, "position",
							Vector2(pos, size.y / 2 - child.size.y / 2), tween_duration)
					pos += gap
				
		elif direction == "Horizontal":
			var gap = (max_size - total_size.x) / (children.size() + 1)
			_tween.tween_property(self, "custom_minimum_size:x",
					total_size.x + gap * (children.size() - 1), tween_duration)
			var pos = 0
			#print()
			for child in children:
				if child is Control:
					#if child == children[-1]:
						#_tween.tween_method((func(progress, node, start_pos, end_pos):
							#node.position = lerp(start_pos, end_pos, progress)
							#print(" ".join([lerp(start_pos, end_pos, progress), progress, start_pos.x, end_pos.x, node.position.x, node.scale]))
						#).bind(child, child.position, Vector2(pos, size.y / 2 - child.size.y / 2),
						#), 0.0, 1.0, tween_duration)
					#else:
						_tween.tween_property(child, "position",
								Vector2(pos, size.y / 2 - child.size.y / 2), tween_duration)
						pos += gap + child.size.x
					
		elif total_size.y > max_size:
			_tween.tween_property(self, "custom_minimum_size:y", max_size, tween_duration)
			var gap = ((max_size
					- ((children[0].size.y + children[-1].size.y) / 2))
					/ (children.size() - 1))
			var pos = 0
			for child in children:
				if child is Control:
					_tween.tween_property(child, "position",
							Vector2(size.x / 2 - child.size.x / 2, pos), tween_duration)
					pos += gap
					
		else:
			var gap = (max_size - total_size.y) / (children.size() + 1)
			_tween.tween_property(self, "custom_minimum_size:y",
					total_size.y + gap * (children.size() - 1), tween_duration)
			var pos = 0
			for child in children:
				if child is Control:
					_tween.tween_property(child, "position",
							Vector2(size.x / 2 - child.size.x / 2, pos), tween_duration)
					pos += gap + child.size.y
