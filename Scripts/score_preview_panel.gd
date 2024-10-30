extends KeepXCentered

const _FADE_IN_DURATION := 0.2
const _FADE_OUT_DURATION := 0.2

@onready var label = $Label

var _tween : Tween

func show_score(score: int, preview: bool = true) -> void:
	visible = true
	if score >= 0:
		label.add_theme_color_override("font_color",
				Globals.TEXT_COLOR.points_gain)
		label.set_text("+" + str(score))
	else:
		label.add_theme_color_override("font_color",
				Globals.TEXT_COLOR.points_loss)
		label.set_text(str(score))
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if preview:
		label.visible_ratio = 1
		scale = Vector2()
		_tween.tween_property(self, "scale", Vector2(1, 1), _FADE_IN_DURATION).set_trans(Tween.TRANS_ELASTIC)
	else:
		label.visible_ratio = 0
		scale = Vector2(1, 1)
		_tween.tween_property(label, "visible_ratio", 1, 0.1)
		_tween.tween_method(func(_x): pass, 0, 0, 0.2)
		_tween.tween_property(self, "scale", Vector2(), _FADE_OUT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await _tween.finished

func hide_score() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(), _FADE_OUT_DURATION)
	_tween.tween_callback((func(): visible = false))
