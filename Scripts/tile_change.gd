extends Resource
class_name TileChange

var tile : HabitatTile
var animal_idx : int
var score_change : int
var money_change : int

func _init(tile_: HabitatTile, animal_idx_: int, score_change_: int = 0,
		money_change_: int = 0) -> void:
	tile = tile_
	animal_idx = animal_idx_
	score_change = score_change_
	money_change = money_change_
