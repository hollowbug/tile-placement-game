extends Animal

func _init():
	exclude = false
	name = "Swan"
	name_plural = "Swans"
	sprite = preload("res://Sprites/swan.png")
	categories = [Globals.ANIMAL_TYPE.BIRD]
	habitats = [Globals.TERRAIN_TYPE.WATER]
	rarity = Globals.RARITY.UNCOMMON
	description = "<points=1> per unique adjacent animal"
	
func calculate_score(changes: Changes, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
	var points = 0
	var names = []
	# Check other animal on this tile
	var other = tile.preview_animals[int(!bool(animal_idx))]
	if other and other.name not in names:
		points += 1
		if other.name != "Chameleon":
			names.append(other.name)
	# Check adjacent tiles
	for other_tile in tile.get_neighbors():
		for i in range(2):
			if other_tile:
				var animal = other_tile.preview_animals[i]
				if animal and animal.name not in names:
					points += 1
					if animal.name != "Chameleon":
						names.append(animal.name)
	changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))
