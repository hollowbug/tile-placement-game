extends Animal

func _init():
	exclude = false
	name = "Raccoon"
	name_plural = "Raccoons"
	sprite = preload("res://Sprites/raccoon.png")
	categories = [Globals.ANIMAL_TYPE.PREDATOR]
	habitats = [Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.COMMON
	description = "<when_placed> <money=5>"

func calculate_score(changes: Changes, tile: HabitatTile, placed_tile: HabitatTile, animal_idx: int) -> void:
	if tile != placed_tile:
		return
	changes.add_tile(TileChange.new(tile, animal_idx, 0, 5))
