extends Animal

func _init():
	exclude = false
	name = "Kangaroo"
	name_plural = "Kangaroos"
	sprite = preload("res://Sprites/kangaroo.png")
	categories = [Globals.ANIMAL_TYPE.HERBIVORE]
	habitats = [Globals.TERRAIN_TYPE.GRASS]
	rarity = Globals.RARITY.COMMON
	description = "<points=1> per empty tile in this <this_terrain>"
	
func placement_preview(changes: TotalScoreChange, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
		var points = 0
		for other_tile in tile.get_habitat(tile.data.terrain[animal_idx]):
			if (!other_tile.data.animal[0]
					and other_tile.data.terrain[0] == tile.data.terrain[animal_idx]):
				points += 1
			elif (other_tile.is_split and !other_tile.data.animal[1]
					and other_tile.data.terrain[1] == tile.data.terrain[animal_idx]):
				points += 1
		changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))

