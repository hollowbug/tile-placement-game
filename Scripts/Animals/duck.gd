extends Animal

func _init():
	exclude = false
	name = "Duck"
	name_plural = "Ducks"
	sprite = preload("res://Sprites/duck.png")
	categories = [Globals.ANIMAL_TYPE.BIRD]
	habitats = [Globals.TERRAIN_TYPE.WATER]
	rarity = Globals.RARITY.COMMON
	description = "<points=1> per <name> in this <this_terrain>"
	
func placement_preview(changes: TotalScoreChange, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
	var points = 0
	for other_tile in tile.get_habitat(tile.data.terrain[animal_idx]):
		for i in range(2):
			var animal = other_tile.data.animal[i]
			if (animal and animal.name == name
					and other_tile.data.terrain[i] == tile.data.terrain[animal_idx]):
				points += 1
	changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))
