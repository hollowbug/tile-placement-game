extends ItemData

var _jungles : int
var _preview_jungles : int

func _init():
	super(-1)
	exclude = false
	name = "Banana"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/banana.png")

func get_description() -> String:
	return Globals.format_string("<points=2> per <terrain={0}> with at least 2 tiles"
			.format([Globals.TERRAIN_TYPE.JUNGLE]))

func on_island_started(item: Item, hex_grid: HexGrid, change: TotalScoreChange) -> void:
	_jungles = 0
	_score(item, hex_grid, change)
	_jungles = _preview_jungles

func on_placement_previewed(item: Item, tile: HabitatTile, change: TotalScoreChange) -> void:
	_score(item, tile.hex_grid, change)

func on_tile_placed(item: Item, tile: HabitatTile, change: TotalScoreChange) -> void:
	_jungles = _preview_jungles

func _score(item: Item, hex_grid: HexGrid, change: TotalScoreChange) -> void:
	_preview_jungles = 0
	for habitat in hex_grid.habitats:
		if habitat.terrain == Globals.TERRAIN_TYPE.JUNGLE and habitat.tiles.size() >= 2:
			_preview_jungles += 1
	if _preview_jungles != _jungles:
		change.add_item(ItemScoreChange.new(item, _preview_jungles - _jungles))
