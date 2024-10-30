extends ItemData

func _init():
	super(-1)
	exclude = false
	name = "Pound of Soil"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/pound_of_soil.png")
		
func get_description() -> String:
	return Globals.format_string("<points=1> when you play a tile")

func on_placement_previewed(item: Item, _tile: HabitatTile, change: TotalScoreChange) -> void:
	change.add_item(ItemScoreChange.new(item, 1))
