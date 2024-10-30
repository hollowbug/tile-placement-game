extends Control
class_name ClickableControl

signal control_clicked
signal control_selected
signal control_unselected

const HOVER_EFFECT_DURATION = 0.2

@export var selectable := true

var hovered = false
var selected = false
#var _shadow := get_node_or_null("Shadow")
var _hover_effect_tween : Tween
var _initial_z : int

func _init():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _ready():
	_initial_z = z_index

func unselect() -> void:
	if selected:
		selected = false
		#control_unselected.emit()
		if !hovered:
			_end_hover_effect()
			
func pop_effect() -> void:
	var target_scale = 1
	if hovered or selected:
		target_scale = 1.2
	if _hover_effect_tween:
		_hover_effect_tween.kill()
	_hover_effect_tween = create_tween()
	_hover_effect_tween.tween_property(self, "scale", Vector2(1.3, 1.3), HOVER_EFFECT_DURATION * 0.2)
	(_hover_effect_tween.tween_property(self, "scale", Vector2(target_scale, target_scale), HOVER_EFFECT_DURATION * 0.8)
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))

func _on_mouse_entered() -> void:
	hovered = true
	_start_hover_effect()

func _on_mouse_exited() -> void:
	hovered = false
	if selected:
		z_index = _initial_z + 1
	else:
		_end_hover_effect()

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if selectable:
			selected = !selected
			if selected:
				control_selected.emit()
			else:
				control_unselected.emit()
		control_clicked.emit()
		accept_event()

func _start_hover_effect() -> void:
	z_index = _initial_z + 2
	if _hover_effect_tween:
		_hover_effect_tween.kill()
	_hover_effect_tween = create_tween()
	_hover_effect_tween.tween_property(self, "scale", Vector2(1.3, 1.3), HOVER_EFFECT_DURATION * 0.2)
	(_hover_effect_tween.tween_property(self, "scale", Vector2(1.2, 1.2), HOVER_EFFECT_DURATION * 0.8)
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))

func _end_hover_effect() -> void:
	z_index = _initial_z
	if _hover_effect_tween:
		_hover_effect_tween.kill()
	_hover_effect_tween = create_tween()
	_hover_effect_tween.tween_property(self, "scale", Vector2(0.9, 0.9), HOVER_EFFECT_DURATION * 0.2)
	(_hover_effect_tween.tween_property(self, "scale", Vector2(1, 1), HOVER_EFFECT_DURATION * 0.8)
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
