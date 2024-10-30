extends ItemData

var _waters : int
var _preview_waters : int

func _init():
	super(-1)
	exclude = false
	name = "Seaweed"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/seaweed.png")

func get_description() -> String:
	return Globals.format_string("<points=1> per <terrain={0}> tile with no animal"
			.format([Globals.TERRAIN_TYPE.WATER]))

func on_island_started(item: Item, hex_grid: HexGrid, change: TotalScoreChange) -> void:
	_waters = 0
	_score(item, hex_grid, change)
	_waters = _preview_waters

func on_placement_previewed(item: Item, tile: HabitatTile, change: TotalScoreChange) -> void:
	_preview_waters = 0
	_score(item, tile.hex_grid, change)

func on_tile_placed(item: Item, tile: HabitatTile, change: TotalScoreChange) -> void:
	_waters = _preview_waters

func _score(item: Item, hex_grid: HexGrid, change: TotalScoreChange) -> void:
	_preview_waters = 0
	for tile in hex_grid.get_all_tiles():
		if tile.data.terrain[0] == Globals.TERRAIN_TYPE.WATER and !tile.data.animal[0]:
			_preview_waters += 1
		elif tile.is_split and tile.data.terrain[1] == Globals.TERRAIN_TYPE.WATER and !tile.data.animal[1]:
			_preview_waters += 1
	if _preview_waters != _waters:
		change.add_item(ItemScoreChange.new(item, _preview_waters - _waters))
