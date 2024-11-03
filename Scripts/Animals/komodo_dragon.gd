extends Animal

func _init():
	exclude = false
	name = "Komodo Dragon"
	name_plural = "Komodo Dragons"
	sprite = preload("res://Sprites/komodo_dragon.png")
	categories = [Globals.ANIMAL_TYPE.REPTILE]
	habitats = [Globals.TERRAIN_TYPE.GRASS]
	rarity = Globals.RARITY.COMMON
	description = "<when_placed> <points=1> per empty tile on the island"

func calculate_score(changes: TileChanges, tile: HabitatTile, placed_tile: HabitatTile, animal_idx: int) -> void:
	if tile != placed_tile:
		return
	var points = 0
	for tile2 in tile.get_all_tiles(true):
		if tile2.is_empty_slot:
			points += 1
	changes.add_tile(TileChange.new(tile, animal_idx, points))
