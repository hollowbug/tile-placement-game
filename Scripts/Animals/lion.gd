extends Animal

func _init():
	exclude = false
	name = "Lion"
	name_plural = "Lions"
	sprite = preload("res://Sprites/lion.png")
	categories = [Globals.ANIMAL_TYPE.PREDATOR]
	habitats = [Globals.TERRAIN_TYPE.JUNGLE]
	rarity = Globals.RARITY.RARE
	description = "<points=5> if this <this_terrain> has at least 4 tiles and no other <name_plural>"
	
func placement_preview(changes: TotalScoreChange, tile: HabitatTile, placed_tile: HabitatTile, animal_idx: int) -> void:
	if tile != placed_tile:
		return
	var points = 0
	#for tile in tile.get_tiles_in_range(1):
		
	changes.add_tile(TileChange.new(tile, animal_idx, 5 - tile.animal_score[animal_idx]))
