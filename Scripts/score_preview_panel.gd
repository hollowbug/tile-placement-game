extends KeepXCentered

const _FADE_IN_DURATION := 0.2
const _FADE_OUT_DURATION := 0.2

func _process(_delta: float) -> void:
	size.y = 0

@onready var labels = [
	$VBoxContainer/Points,
	$VBoxContainer/Money,
]

var _tween : Tween

func show_score(score: int, preview: bool = true, money: int = 0) -> void:
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if preview:
		labels[0].visible_ratio = 1
		labels[1].visible_ratio = 1
		scale = Vector2()
		_tween.tween_property(self, "scale", Vector2(1, 1), _FADE_IN_DURATION).set_trans(Tween.TRANS_ELASTIC)
	elif score != 0 and money != 0:
		print("WARNING: Trying to display score and money change simultaneously."
				+ " This may result in unwanted behavior.")
	var values = [score, money]
	for i in range(2):
		if values[i] == 0:
			labels[i].visible = false
			continue
		labels[i].visible = true
		var string = str(score) if i == 0 else "$" + str(money)
		if values[i] > 0:
			if i == 0:
				labels[i].add_theme_color_override("font_color",
						Globals.TEXT_COLOR.points_gain)
			else:
				labels[i].add_theme_color_override("font_color",
						Globals.TEXT_COLOR.money)
			labels[i].set_text("+" + string)
		else:
			labels[i].add_theme_color_override("font_color",
					Globals.TEXT_COLOR.points_loss)
			labels[i].set_text(string)
		if !preview:
			labels[i].visible_ratio = 0
			scale = Vector2(1, 1)
			_tween.tween_property(labels[i], "visible_ratio", 1, 0.1)
			_tween.tween_method(func(_x): pass, null, null, 0.2) # Wait 0.2 seconds
			_tween.tween_property(self, "scale", Vector2(), _FADE_OUT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			await _tween.finished

func hide_score() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(), _FADE_OUT_DURATION)
	_tween.tween_callback((func(): visible = false))
