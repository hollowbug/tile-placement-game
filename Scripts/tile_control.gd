extends ClickableControl
class_name TileControl

var data : TileData_
var _animal_panel = []

@onready var _tile := $Tile
@onready var _tile_info := %TileInfo
@onready var _label_terrains = %Terrains
@onready var _SPRITES = {
	side1 = $Tile/Side1,
	side1Animal = $"Tile/Side1/Animal",
	side2 = $Tile/Side2,
	side2Animal = $"Tile/Side2/Animal",
	full = $Tile/Full,
	fullAnimal = $"Tile/Full/Animal",
}

func _ready():
	for i in range(2):
		_animal_panel.append({
			panel = get_node("%AnimalPanel" + str(i)),
			name = get_node("%AnimalPanel" + str(i) + "/%Name"),
			details = get_node("%AnimalPanel" + str(i) + "/%Details"),
			description = get_node("%AnimalPanel" + str(i) + "/%Description"),
		})

func set_data(data_: TileData_) -> void:
	if not is_node_ready():
		await ready
	data = data_
	_SPRITES.side1.visible = data.terrain[0] != data.terrain[1]
	_SPRITES.side2.visible = data.terrain[0] != data.terrain[1]
	_SPRITES.full.visible = data.terrain[0] == data.terrain[1]
	_label_terrains.set_text("[center]" + data.get_terrain_string())
	
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
			
	for i in range(2):
		if data.animal[i]:
			_animal_panel[i].panel.visible = true
			_animal_panel[i].name.set_text("[center]" + data.get_animal_name(i))
			_animal_panel[i].details.set_text("[center]" + Globals.RARITY_STRING[data.animal[i].rarity] + " "
					+ data.animal[i].get_category_string())
			_animal_panel[i].description.set_text("[center]" + data.get_animal_description(i))
		else:
			_animal_panel[i].panel.visible = false

func _on_mouse_entered() -> void:
	super()
	_tile_info.visible = true

func _on_mouse_exited() -> void:
	super()
	_tile_info.visible = false
