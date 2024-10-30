extends ScoreChange
class_name TileScoreChange

var tile : HabitatTile
var animal_idx : int

func _init(tile_: HabitatTile, animal_idx_: int, inc: int = 0, dec: int = 0) -> void:
	tile = tile_
	animal_idx = animal_idx_
	increase = inc
	decrease = dec
