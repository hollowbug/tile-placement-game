extends Animal

func _init():
	exclude = false
	name = "Wolf"
	name_plural = "Wolves"
	sprite = preload("res://Sprites/wolf.png")
	categories = [Globals.ANIMAL_TYPE.PREDATOR]
	habitats = [Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.COMMON
	description = ("<points=1> per adjacent <name>"
			+ "\n<points=1> per adjacent <animal_category={0}>"
			.format([Globals.ANIMAL_TYPE.HERBIVORE]))
	function = func(tile: HabitatTile, animal_idx: int) -> TileScoreChange:
		var points = [0]
		var check_animal = func(animal: Animal) -> void:
			if animal.name == name:
				points[0] += 1
			if animal.has_category(Globals.ANIMAL_TYPE.HERBIVORE):
				points[0] += 1
		# Check other animal on this tile
		var other = tile.data.animal[int(!bool(animal_idx))]
		if other:
			check_animal.call(other)
		# Check adjacent tiles
		for other_tile in tile.get_neighbors():
			for i in range(2):
				var animal = other_tile.data.animal[i]
				if animal:
					check_animal.call(animal)
		return TileScoreChange.new(tile, animal_idx, points[0] - tile.animal_score[animal_idx])