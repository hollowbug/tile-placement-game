extends Animal

func _init():
	exclude = false
	name = "Lion"
	name_plural = "Lions"
	sprite = preload("res://Sprites/lion.png")
	categories = [Globals.ANIMAL_TYPE.PREDATOR]
	habitats = [Globals.TERRAIN_TYPE.GRASS]
	rarity = Globals.RARITY.RARE
	description = "<when_played> Remove animals from adjacent tiles and gain <points=3> for each one removed"
	
func placement_preview(changes: TileChanges, tile: HabitatTile, placed_tile: HabitatTile, animal_idx: int) -> void:
	if tile != placed_tile:
		return
	var points = 0
	for tile2 in tile.get_tiles_in_range(1):
		for i in range(2):
			if tile2.preview_animals[i]:
				tile2.preview_animals[i] = null
				var change = TileChange.new(tile2, i)
				changes.add_tile(change)
				points += 3
	changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))
