extends Resource
class_name Habitat

var terrain : int
var tiles : Array[HabitatTile]

func _init(terrain_: int, tiles_: Array[HabitatTile]):
	terrain = terrain_
	tiles = tiles_
