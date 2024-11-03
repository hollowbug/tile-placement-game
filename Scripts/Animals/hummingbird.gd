extends Animal

func _init():
	exclude = false
	name = "Hummingbird"
	name_plural = "Hummingbirds"
	sprite = preload("res://Sprites/hummingbird.png")
	categories = [Globals.ANIMAL_TYPE.BIRD]
	habitats = [Globals.TERRAIN_TYPE.DESERT]
	rarity = Globals.RARITY.MYTHICAL
	description = "<when_placed> Permanently add random animals to adjacent tiles"

func placement_preview(changes: TileChanges, tile: HabitatTile, placed_tile: HabitatTile, animal_idx: int) -> void:
	if tile != placed_tile:
		return
	for tile2 in tile.get_neighbors():
		for i in range(2):
			if i == 1 and !tile.is_split:
				break
			if !tile2.preview_animals[i] and !tile2.data.animal[i]:
				var animal = RandomAnimal.new()
				animal.permanent = true
				tile2.preview_animals[i] = animal
				var change = TileChange.new(tile2, i)
				changes.add_tile(change)
