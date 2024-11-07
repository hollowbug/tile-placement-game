extends ItemData

var _largest : int
var _preview_largest : int

func _init(id_: int):
	super(id_)
	exclude = false
	name = "Pine Cone"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/pine_cone.png")

func get_description() -> String:
	return Globals.format_string("<points=1> per tile in largest <terrain={0}>"
			.format([Globals.TERRAIN_TYPE.FOREST1]))

func on_island_started(item: Item, hex_grid: HexGrid, changes: Changes) -> void:
	_largest = 0
	_score(item, hex_grid, changes)
	_largest = _preview_largest

func on_placement_previewed(item: Item, tile: HabitatTile, changes: Changes) -> void:
	_score(item, tile.hex_grid, changes)

func on_tile_placed(_item: Item, _tile: HabitatTile, _changes: Changes) -> void:
	_largest = _preview_largest

func _score(item: Item, hex_grid: HexGrid, changes: Changes) -> void:
	_preview_largest = 0
	for habitat in hex_grid.habitats:
		if habitat.terrain == Globals.TERRAIN_TYPE.FOREST1:
			_preview_largest = max(_preview_largest, habitat.tiles.size())
	if _preview_largest != _largest:
		changes.add_item(ItemScoreChange.new(item, _preview_largest - _largest))
