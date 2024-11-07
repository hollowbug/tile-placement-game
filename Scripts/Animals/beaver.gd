extends Animal

func _init():
	exclude = false
	name = "Beaver"
	name_plural = "Beavers"
	sprite = preload("res://Sprites/beaver.png")
	categories = [Globals.ANIMAL_TYPE.RODENT]
	habitats = [Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.COMMON
	description = ("<points=1> per connected <animal_category={0}> in a straight line"
			.format([Globals.ANIMAL_TYPE.RODENT]))
	
func calculate_score(changes: Changes, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
		var points = 0
		
		# Check other animal on this tile
		var other = tile.preview_animals[int(!bool(animal_idx))]
		if other and other.name == name:
			points += 1
			
		# Check each direction
		for dir in range(6):
			for tile2 in tile.get_tiles_in_direction(dir, true):
				var rodent = false
				for i in range(2):
					var animal = tile2.preview_animals[i]
					if animal and animal.has_category(Globals.ANIMAL_TYPE.RODENT):
						points += 1
						rodent = true
				if !rodent:
					break
		changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))

