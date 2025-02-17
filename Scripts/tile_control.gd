extends ClickableControl
class_name TileControl

var data : TileData_

@onready var _highlight := %Selected
@onready var _SPRITES = {
	side1 = $Tile/Side1,
	side1Animal = $"Tile/Side1/Animal",
	side2 = $Tile/Side2,
	side2Animal = $"Tile/Side2/Animal",
	full = $Tile/Full,
	fullAnimal = $"Tile/Full/Animal",
}

func set_data(data_: TileData_) -> void:
	if not is_node_ready():
		await ready
	data = data_
	_SPRITES.side1.visible = data.terrain[0] != data.terrain[1]
	_SPRITES.side2.visible = data.terrain[0] != data.terrain[1]
	_SPRITES.full.visible = data.terrain[0] == data.terrain[1]
	
	if data.terrain[0] == data.terrain[1]:
		_SPRITES.full.set_texture(Globals.TERRAIN[data.terrain[0]].sprite_full)
		_SPRITES.fullAnimal.visible = true if data.animal[0] else false
		if data.animal[0]:
			_SPRITES.fullAnimal.set_texture(data.animal[0].sprite)
	else:
		_SPRITES.side1.set_texture(Globals.TERRAIN[data.terrain[0]].sprite_half)
		_SPRITES.side2.set_texture(Globals.TERRAIN[data.terrain[1]].sprite_half)
		_SPRITES.side1Animal.visible = true if data.animal[0] else false
		_SPRITES.side2Animal.visible = true if data.animal[1] else false
		if data.animal[0]:
			_SPRITES.side1Animal.set_texture(data.animal[0].sprite)
		if data.animal[1]:
			_SPRITES.side2Animal.set_texture(data.animal[1].sprite)

func _on_mouse_entered() -> void:
	super()
	SignalBus.tile_control_hovered.emit(self)
	#_tile_info.modulate.a = 1

func _on_mouse_exited() -> void:
	super()
	SignalBus.tile_control_hover_ended.emit(self)
	#_tile_info.modulate.a = 0


func _on_control_selected() -> void:
	_highlight.show()


func _on_control_unselected() -> void:
	_highlight.hide()
