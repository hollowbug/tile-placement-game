extends Animal

func _init():
	exclude = false
	name = "Panda"
	name_plural = "Pandas"
	sprite = preload("res://Sprites/panda.png")
	categories = [Globals.ANIMAL_TYPE.HERBIVORE]
	habitats = [Globals.TERRAIN_TYPE.JUNGLE]
	rarity = Globals.RARITY.COMMON
	description = "<points=1> per tile in this Habitat"
	function = func(tile: HabitatTile, animal_idx: int) -> TileScoreChange:
		var points = 0
		for other_tile in tile.get_habitat(tile.data.terrain[animal_idx]):
			if (other_tile.data.terrain[0] == tile.data.terrain[animal_idx]):
				points += 1
			elif (other_tile.is_split
					and other_tile.data.terrain[1] == tile.data.terrain[animal_idx]):
				points += 1
		return TileScoreChange.new(tile, animal_idx, points - tile.animal_score[animal_idx])
