extends Object
class_name TileChanges

var change : int = 0
var tiles : Array[TileChange] = []
var items : Array[ItemScoreChange] = []

func add(other: TileChanges) -> TileChanges:
	change += other.change
	tiles.append_array(other.tiles)
	items.append_array(other.items)
	return self

func add_tile(tile: TileChange) -> void:
	change += tile.score_change
	for tile2 in tiles:
		if tile.tile == tile2.tile and tile.animal_idx == tile2.animal_idx:
			tile2.score_change += tile.score_change
			#tile2.animal_removed = tile.animal_removed or tile2.animal_removed
			#tile2.animal_added = tile.animal_added or tile2.animal_added
			return
	tiles.append(tile)
	
func add_item(item: ItemScoreChange) -> void:
	items.append(item)
	change += item.score_change
