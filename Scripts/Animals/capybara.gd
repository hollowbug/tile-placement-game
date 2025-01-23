extends Animal

func _init():
	exclude = false
	name = "Capybara"
	name_plural = "Capybaras"
	sprite = preload("res://Sprites/capybara.png")
	categories = [Globals.ANIMAL_TYPE.RODENT]
	habitats = [Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.UNCOMMON
	description = ("<points=1> whenever you place a <animal_category={0}>"
			.format([Globals.ANIMAL_TYPE.RODENT]))


func calculate_score(changes: Changes, tile: HabitatTile, placed_tile: HabitatTile, animal_idx: int) -> void:
	if tile == placed_tile:
		return
	
	var points = 0
	
	for i in range(2):
		var animal = placed_tile.preview_animals[i]
		if animal and animal.has_category(Globals.ANIMAL_TYPE.RODENT):
			points += 1
	changes.add_tile(TileChange.new(tile, animal_idx, points))
