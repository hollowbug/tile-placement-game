extends Node3D
class_name Tile

signal mouse_entered(tile: Tile)
signal mouse_exited(tile: Tile)
signal input_event(tile: Tile, event: InputEvent)

var hex_grid: HexGrid
var coordinates : Vector2i
var is_empty_slot := true

func get_neighbors(include_empty_cells: bool = false) -> Array[Tile]:
	var arr = hex_grid.get_neighbors(self, include_empty_cells)
	var result = arr.filter(func(x): return true if x else false)
	return result
	
func get_tiles_in_range(range: int, include_empty_cells: bool = false,
		include_self: bool = false) -> Array[Tile]:
	return hex_grid.get_tiles_in_range(self, range, include_empty_cells, include_self)

func get_tiles_in_direction(direction: int, stop_at_empty: bool = false,
		include_empty_cells: bool = false) -> Array[Tile]:
	return hex_grid.get_tiles_in_direction(self, direction, stop_at_empty, include_empty_cells)

func get_all_tiles(include_empty_cells: bool = false, include_self: bool = true) -> Array[Tile]:
	var arr = hex_grid.get_all_tiles(include_empty_cells)
	if !include_self:
		arr.remove(self)
	return arr

func get_all_habitats() -> Array[Habitat]:
	return hex_grid.get_all_habitats()
