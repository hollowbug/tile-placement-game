extends Animal

func _init():
	exclude = false
	name = "Kingsnake"
	name_plural = "Kingsnakes"
	sprite = preload("res://Sprites/kingsnake.png")
	categories = [Globals.ANIMAL_TYPE.REPTILE]
	habitats = [Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.FOREST1, Globals.TERRAIN_TYPE.DESERT]
	rarity = Globals.RARITY.COMMON
	description = "<points=3> if placed on the edge of the island"

func calculate_score(changes: Changes, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
	var edges = range(6)
	if tile.is_split:
		var start = tile.rotations + animal_idx*3
		edges = range(start, start + 3)
	var neighbors = tile.hex_grid.get_neighbors(tile, true)
	for i in edges:
		if !neighbors[i % 6]:
			changes.add_tile(TileChange.new(tile, animal_idx, 3 - tile.animal_score[animal_idx]))
			return
	changes.add_tile(TileChange.new(tile, animal_idx, -tile.animal_score[animal_idx]))
