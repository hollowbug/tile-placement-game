extends Animal

func _init():
	exclude = false
	name = "Crocodile"
	name_plural = "Crocodiles"
	sprite = preload("res://Sprites/crocodile.png")
	categories = [Globals.ANIMAL_TYPE.REPTILE]
	habitats = [Globals.TERRAIN_TYPE.WATER]
	rarity = Globals.RARITY.UNCOMMON
	description = "<points=3> per animal on tiles in a straight line between this and another <name>"

func calculate_score(changes: TileChanges, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
	var highest = 0
	for dir in range(6):
		var animals = 0
		for tile2 in tile.get_tiles_in_direction(dir):
			for i in range(2):
				var animal = tile2.preview_animals[i]
				if animal and (animal.name == name or animal.name == "Chameleon"):
					highest = max(highest, animals)
			for i in range(2):
				if tile2.preview_animals[i]:
					animals += 1
	changes.add_tile(TileChange.new(tile, animal_idx, highest))
