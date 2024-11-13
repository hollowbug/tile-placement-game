extends Animal

func _init():
	exclude = false
	name = "King Cobra"
	name_plural = "King Cobras"
	sprite = preload("res://Sprites/king_cobra.png")
	categories = [Globals.ANIMAL_TYPE.REPTILE]
	habitats = [Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.JUNGLE]
	rarity = Globals.RARITY.RARE
	description = "<points=3> per adjacent Kingsnake"

func calculate_score(changes: Changes, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
	var points = 0
	# Check other animal on this tile
	var other = tile.preview_animals[int(!bool(animal_idx))]
	if other and other.name == "Kingsnake":
		points += 3
	# Check adjacent tiles
	for other_tile in tile.get_neighbors():
		for i in range(2):
			if other_tile:
				var animal = other_tile.preview_animals[i]
				if animal and animal.name == "Kingsnake":
					points += 3
	changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))
