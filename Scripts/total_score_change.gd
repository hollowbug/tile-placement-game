extends Object
class_name TotalScoreChange

var change : int = 0
var tiles : Array[TileScoreChange] = []
var items : Array[ItemScoreChange] = []

func add(other: TotalScoreChange) -> TotalScoreChange:
	change += other.change
	tiles.append_array(other.tiles)
	items.append_array(other.items)
	return self

func add_tile(tile: TileScoreChange) -> void:
	tiles.append(tile)
	change += tile.total
	
func add_item(item: ItemScoreChange) -> void:
	items.append(item)
	change += item.total
