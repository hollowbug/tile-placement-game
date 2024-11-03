extends Animal

func _init():
	exclude = false
	name = "Hawk"
	name_plural = "Hawks"
	sprite = preload("res://Sprites/hawk.png")
	categories = [Globals.ANIMAL_TYPE.PREDATOR, Globals.ANIMAL_TYPE.BIRD]
	habitats = [Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.UNCOMMON
	description = (("<points=1> per <animal_category={0}> within 2 tiles"
			+ "\n <points=-3> per <animal_category={1}> within 2 tiles")
			.format([Globals.ANIMAL_TYPE.RODENT, Globals.ANIMAL_TYPE.PREDATOR]))

func calculate_score(changes: TileChanges, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
		var points = [0]
		var check_animal = func(animal: Animal) -> void:
			if animal.has_category(Globals.ANIMAL_TYPE.RODENT):
				points[0] += 1
			if animal.has_category(Globals.ANIMAL_TYPE.PREDATOR):
				points[0] -= 3
		# Check other animal on this tile
		var other = tile.preview_animals[int(!bool(animal_idx))]
		if other:
			check_animal.call(other)
		# Check other tiles within range
		for other_tile in tile.get_tiles_in_range(2):
			for i in range(2):
				var animal = other_tile.preview_animals[i]
				if animal:
					check_animal.call(animal)
		changes.add_tile(TileChange.new(tile, animal_idx, points[0] - tile.animal_score[animal_idx]))

