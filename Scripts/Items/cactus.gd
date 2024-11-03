extends ItemData

var _deserts : int
var _preview_deserts : int

func _init(id_: int):
	super(id_)
	exclude = false
	name = "Cactus"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/cactus.png")

func get_description() -> String:
	return Globals.format_string("<points=1> per <terrain={0}> Habitat"
			.format([Globals.TERRAIN_TYPE.DESERT]))

func on_island_started(item: Item, hex_grid: HexGrid, change: TileChanges) -> void:
	_deserts = 0
	_score(item, hex_grid, change)
	_deserts = _preview_deserts

func on_placement_previewed(item: Item, tile: HabitatTile, change: TileChanges) -> void:
	_score(item, tile.hex_grid, change)

func on_tile_placed(item: Item, tile: HabitatTile, change: TileChanges) -> void:
	_deserts = _preview_deserts

func _score(item: Item, hex_grid: HexGrid, change: TileChanges) -> void:
	_preview_deserts = 0
	for habitat in hex_grid.habitats:
		if habitat.terrain == Globals.TERRAIN_TYPE.DESERT:
			_preview_deserts += 1
	if _preview_deserts != _deserts:
		change.add_item(ItemScoreChange.new(item, _preview_deserts - _deserts))
