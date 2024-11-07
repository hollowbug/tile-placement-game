extends Animal

var points = 1

func _init():
	exclude = false
	name = "Deer"
	name_plural = "Deer"
	sprite = preload("res://Sprites/deer.png")
	categories = [Globals.ANIMAL_TYPE.HERBIVORE]
	habitats = [Globals.TERRAIN_TYPE.FOREST1]
	rarity = Globals.RARITY.UNCOMMON
	description = "<when_placed> <var> and permanently increase this by 1"

func get_description() -> String:
	return super().replace("<var>", "<points={0}>".format([points]))

func calculate_score(changes: Changes, tile: HabitatTile, placed_tile: HabitatTile, animal_idx: int) -> void:
	if tile != placed_tile:
		return
	changes.add_tile(TileChange.new(tile, animal_idx, points - tile.animal_score[animal_idx]))

func on_tile_placed(tile: HabitatTile, placed_tile: HabitatTile, _animal_idx: int) -> void:
	if tile == placed_tile:
		points += 1
		tile.update_description()
