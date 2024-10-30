extends Animal

func _init():
	exclude = false
	name = "Camel"
	name_plural = "Camels"
	sprite = preload("res://Sprites/camel.png")
	categories = [Globals.ANIMAL_TYPE.HERBIVORE]
	habitats = [Globals.TERRAIN_TYPE.DESERT]
	rarity = Globals.RARITY.UNCOMMON
	description = "<points=2> per empty tile in this <this_terrain>"

func placement_preview(changes: TotalScoreChange, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
	var points = 0
	for other_tile in tile.get_habitat(tile.data.terrain[animal_idx]):
		if (!other_tile.data.animal[0]
				and other_tile.data.terrain[0] == tile.data.terrain[animal_idx]):
			points += 2
		elif (other_tile.is_split and !other_tile.data.animal[1]
				and other_tile.data.terrain[1] == tile.data.terrain[animal_idx]):
			points += 2
	changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))
