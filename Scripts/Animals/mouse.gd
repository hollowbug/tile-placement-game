extends Animal

func _init():
	exclude = false
	name = "Mouse"
	name_plural = "Mice"
	sprite = preload("res://Sprites/mouse.png")
	categories = [Globals.ANIMAL_TYPE.RODENT]
	habitats = [Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.COMMON
	description = ("<points=1>\n"
			+ "<points=1> per adjacent <animal_category={0}>".format([Globals.ANIMAL_TYPE.RODENT]))
	
func placement_preview(changes: TotalScoreChange, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
		var points = 1
		# Check other animal on this tile
		var other = tile.data.animal[int(!bool(animal_idx))]
		if other and other.has_category(Globals.ANIMAL_TYPE.RODENT):
			points += 1
		# Check adjacent tiles
		for other_tile in tile.get_neighbors():
			for i in range(2):
				if other_tile:
					var animal = other_tile.data.animal[i]
					if animal and animal.has_category(Globals.ANIMAL_TYPE.RODENT):
						points += 1
		changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))

