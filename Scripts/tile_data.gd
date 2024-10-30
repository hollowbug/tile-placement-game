extends Resource
class_name TileData_

static var max_id = 0

var id : int
var terrain : Array[int]
var animal : Array[Animal]

func _init(terrain0: int = -1, terrain1: int = -1,
		animal0: Animal = null, animal1: Animal = null, id_: int = -1):
	terrain = [terrain0, terrain1]
	animal = [animal0, animal1]
	if id_ == -1:
		id = max_id
		max_id += 1
	else:
		id = id_

func copy(keep_id: bool = true) -> TileData_:
	var id_ = id if keep_id else -1
	return TileData_.new(terrain[0], terrain[1], animal[0], animal[1], id_)

func get_terrain_string() -> String:
	var string = Globals.TERRAIN[terrain[0]].name
	if terrain[0] != terrain[1]:
		string = Globals.TERRAIN[terrain[1]].name + " / " + string
	return string

func get_animal_name(animal_idx: int) -> String:
	if animal[animal_idx]:
		return animal[animal_idx].name
	return ""

func get_animal_description(animal_idx: int) -> String:
	if animal[animal_idx] and animal[animal_idx].description:
		return animal[animal_idx].get_description()
	return ""
