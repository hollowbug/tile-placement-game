extends PanelContainer

const SLIDE_DURATION = 0.3

@onready var target_position = position

func slide_in() -> void:
	visible = true
	position.y = get_viewport_rect().end.y/2 + 100
	var tween = (create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			.tween_property(self, "position", target_position, SLIDE_DURATION))
	await tween.finished
