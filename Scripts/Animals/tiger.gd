extends Animal

func _init():
	exclude = false
	name = "Tiger"
	name_plural = "Tigers"
	sprite = preload("res://Sprites/tiger.png")
	categories = [Globals.ANIMAL_TYPE.PREDATOR]
	habitats = [Globals.TERRAIN_TYPE.JUNGLE]
	rarity = Globals.RARITY.UNCOMMON
	description = "<points=5> if this <this_terrain> has at least 4 tiles and no other <name_plural>"
	
func placement_preview(changes: TotalScoreChange, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
		var habitat = tile.get_habitat(tile.data.terrain[animal_idx])
		if habitat.size() < 4:
			return TileChange.new(tile, animal_idx, -tile.animal_score[animal_idx])
		for other_tile in habitat:
			if tile == other_tile:
				continue
			for i in range(2):
				if other_tile.data.animal[i].name == name and other_tile.data.terrain[i] == tile.data.terrain[i]:
					return TileChange.new(tile, animal_idx, -tile.animal_score[animal_idx])
		changes.add_tile(TileChange.new(tile, animal_idx, 5 - tile.animal_score[animal_idx]))

