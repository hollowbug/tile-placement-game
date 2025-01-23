extends Animal

func _init():
	exclude = false
	name = "Squirrel"
	name_plural = "Squirrels"
	sprite = preload("res://Sprites/squirrel.png")
	categories = [Globals.ANIMAL_TYPE.RODENT]
	habitats = [Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.COMMON
	description = ("<points=1> whenever you place a <animal_category={0}>"
			.format([Globals.ANIMAL_TYPE.RODENT]))

func calculate_score(changes: Changes, tile: HabitatTile, _placed_tile: HabitatTile, animal_idx: int) -> void:
	var points = 0
	
	for i in range(2):
		var animal = _placed_tile.preview_animals[i]
		if animal and animal.has_category(Globals.ANIMAL_TYPE.RODENT):
			points += 1
	changes.add_tile(TileChange.new(tile, animal_idx, points))
