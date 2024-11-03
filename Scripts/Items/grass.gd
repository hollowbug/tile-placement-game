extends ItemData

var _plains : int
var _preview_plains : int

func _init(id_: int):
	super(id_)
	exclude = false
	name = "Grass"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/grass.png")

func get_description() -> String:
	return Globals.format_string("<points=1> per <terrain={0}> tile on the edge of the island"
			.format([Globals.TERRAIN_TYPE.GRASS]))

func on_island_started(item: Item, hex_grid: HexGrid, change: TileChanges) -> void:
	_plains = 0
	_score(item, hex_grid, change)
	_plains = _preview_plains

func on_placement_previewed(item: Item, tile: HabitatTile, change: TileChanges) -> void:
	_preview_plains = 0
	_score(item, tile.hex_grid, change)

func on_tile_placed(item: Item, tile: HabitatTile, change: TileChanges) -> void:
	_plains = _preview_plains

func _score(item: Item, hex_grid: HexGrid, change: TileChanges) -> void:
	_preview_plains = 0
	for tile in hex_grid.get_all_tiles():
		var neighbors = hex_grid.get_neighbors(tile, true)
		for i in range(6):
			if !neighbors[i] and tile.edges[i] == Globals.TERRAIN_TYPE.GRASS:
				_preview_plains += 1
				break
	if _preview_plains != _plains:
		change.add_item(ItemScoreChange.new(item, _preview_plains - _plains))
