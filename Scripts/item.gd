extends ClickableControl
class_name Item

var data : ItemData
var _animal_panel = []

@onready var _popup := %Popup
@onready var _description := %Description
@onready var _score_rect := %ScoreRect

func set_data(data_: ItemData) -> void:
	if not is_node_ready():
		await ready
	data = data_
	%Sprite.set_texture(data_.sprite) 
	%Name.set_text(data_.name)
	%Rarity.set_text("[center]" + Globals.RARITY_STRING[data.rarity])
	if data.get_description:
		_description.visible = true
		_description.set_text("[center]" + data.get_description.call())
	else:
		_description.visible = false

func show_score(change: ItemScoreChange, preview: bool = true) -> void:
	await _score_rect.show_score(change.score_change, preview, change.money_change)
	
func hide_score() -> void:
	_score_rect.hide_score()

func _on_mouse_entered() -> void:
	super()
	_popup.visible = true

func _on_mouse_exited() -> void:
	super()
	_popup.visible = false
