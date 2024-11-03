extends Animal

func _init():
	exclude = false
	name = "Fennec Fox"
	name_plural = "Fennec Foxes"
	sprite = preload("res://Sprites/fennec_fox.png")
	categories = [Globals.ANIMAL_TYPE.PREDATOR]
	habitats = [Globals.TERRAIN_TYPE.DESERT]
	rarity = Globals.RARITY.RARE
	description = ("<points=3> per different <rarity={0}> animal on the island"
			.format([Globals.RARITY.RARE]))
	
func calculate_score(changes: TileChanges, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
		var points = 0
		var animal_names = []
		for tile2 in tile.get_all_tiles():
			for i in range(2):
				var animal = tile2.preview_animals[i]
				if animal and (animal.name == "Chameleon" or 
						(animal and animal.rarity == Globals.RARITY.RARE and animal.name not in animal_names)):
					animal_names.append(animal.name)
					points += 3
		changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))
