extends Object
class_name Changes

var score_change : int = 0
var money_change : int = 0
var tiles : Array[TileChange] = []
var items : Array[ItemScoreChange] = []

func add(other: Changes) -> Changes:
	score_change += other.score_change
	tiles.append_array(other.tiles)
	items.append_array(other.items)
	return self

func add_tile(tile: TileChange) -> void:
	score_change += tile.score_change
	money_change += tile.money_change
	for tile2 in tiles:
		if tile.tile == tile2.tile and tile.animal_idx == tile2.animal_idx:
			tile2.score_change += tile.score_change
			tile2.money_change += tile.money_change
			return
	tiles.append(tile)

func add_item(item: ItemScoreChange) -> void:
	items.append(item)
	score_change += item.score_change
	money_change += item.money_change
