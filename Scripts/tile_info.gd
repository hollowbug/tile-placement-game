extends PanelContainer

var _animal_panel = []

@onready var _label_terrains = %Terrains
@onready var bottom = position.y + size.y

func _ready():
	for i in range(2):
		_animal_panel.append({
			panel = get_node("%AnimalPanel" + str(i)),
			name = get_node("%AnimalPanel" + str(i) + "/%Name"),
			details = get_node("%AnimalPanel" + str(i) + "/%Details"),
			description = get_node("%AnimalPanel" + str(i) + "/%Description"),
		})


# This is needed to counteract Godot's shenanigans
func _process(_delta: float) -> void:
	#position.y = bottom - size.y
	size = Vector2()


func set_data(data: TileData_) -> void:
	_label_terrains.set_text("[center]" + data.get_terrain_string())
	for i in range(2):
		if data.animal[i]:
			_animal_panel[i].panel.visible = true
			_animal_panel[i].name.set_text("[center]" + data.get_animal_name(i))
			_animal_panel[i].details.set_text("[center]" + Globals.RARITY_STRING[data.animal[i].rarity] + " "
					+ data.animal[i].get_category_string())
			_animal_panel[i].description.set_text("[center]" + data.get_animal_description(i))
		else:
			_animal_panel[i].panel.visible = false
	
