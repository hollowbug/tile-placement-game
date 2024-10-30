extends Node3D
class_name HexGrid

signal tile_placed(tile: HabitatTile)
signal score_previewed(tile: HabitatTile, change: TotalScoreChange)
signal score_preview_ended
signal score_changed(change: int)

const AXIAL_DIRECTION_VECTORS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]
static var _BASE_TILE_SCENE = load("res://Scenes/available_cell.tscn")
static var _HABITAT_TILE_SCENE = load("res://Scenes/habitat_tile.tscn")

var num_empty_cells : int
var habitats: Array[Habitat] = []

var _grid : Dictionary
var _base_tiles: Array[Tile]
var _current_tile: HabitatTile
var _hovered_available_cell: Tile
var _placement_preview: TotalScoreChange

###
# OVERRIDE FUNCTIONS
###

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		# Maybe display selected tile at mouse position
		# when not hovering an emtpy slot?
		pass
	
###
# PUBLIC FUNCTIONS
###
	
func set_current_tile(tile: TileData_) -> void:
	if _current_tile:
		_current_tile.queue_free()
		_current_tile = null
	if tile:
		_current_tile = _create_habitat_tile(tile)
		#_current_tile.set_material(_INVALID_PLACE_OVERRIDE_MATERIAL)
		_current_tile.enable_colliders(false)
		_current_tile.hide_()

func create_island(num_empty_slots: int, starting_tiles: Array[TileData_]) -> void:
	# NOTE: WILL HANG IF EMPTY SLOTS + STARTING TILES IS OVER 15;
	# NEEDS TO BE ADJUSTED TO ADD ADDITIONAL TILES IN SUITABLE LOCATIONS
	num_empty_cells = num_empty_slots
	var rand_order = starting_tiles.duplicate()
	_grid = {}
	_base_tiles = []
	for i in range(num_empty_slots):
		rand_order.append(null)
	rand_order.shuffle()
	for next_tile in rand_order:
		var pos: Vector2i
		if _base_tiles.is_empty():
			pos = Vector2i(0, 0)
		else:
			# Pick a random position for next tile
			while true:
				var rand = _base_tiles.pick_random()
				var rand_offset = randi() % 6
				pos = _axial_neighbor(rand.coordinates, rand_offset)
				if ((pos.x not in _grid or pos.y not in _grid[pos.x])
						and _axial_distance(pos, Vector2i.ZERO) < 3
						and pos.y < 2 and pos != Vector2i(1, 1)):
					break
		# Place base tile (rock)
		var world_pos = _axial_to_world(pos)
		var tile = _BASE_TILE_SCENE.instantiate()
		tile.coordinates = pos
		tile.position = world_pos
		add_child(tile)
		_base_tiles.append(tile)
		if next_tile:
			# Place starting tile
			tile = _create_habitat_tile(next_tile)
			tile.coordinates = pos
			tile.position = world_pos
		else:
			tile.mouse_entered.connect(_on_available_cell_mouse_entered)
			tile.mouse_exited.connect(_on_available_cell_mouse_exited)
			tile.input_event.connect(_on_available_cell_input_event)
		# Add tile to grid
		if pos.x in _grid:
			_grid[pos.x][pos.y] = tile
		else:
			_grid[pos.x] = { pos.y : tile }
		if next_tile:
			var neighbors = get_neighbors(tile)
			tile.preview_placement(neighbors)
			tile.commit_placement()
			#tile.autotile(neighbors)
			#_autotile_neighbors(tile)
	_clear_preview()
	
	# Center camera over island
	var min_x = 0
	var max_x = 0
	var min_z = 0
	var max_z = 0
	for tile in _base_tiles:
		min_x = min(min_x, tile.position.x)
		max_x = max(max_x, tile.position.x)
		min_z = min(min_z, tile.position.z)
		max_z = max(max_z, tile.position.z)
	var midpoint = Vector3((min_x + max_x) / 2.0, 0, (min_z + max_z) / 2.0)
	#print("min_x = ", min_x, ", max_x = ", max_x, ", min_z = ", min_z, ", max_z = ", max_z)
	#print("midpoint: ", midpoint)
	for tile in _base_tiles:
		var dist = tile.position.distance_to(midpoint)
		tile.scale.y = max(1, 10 - dist * 2.5)
	var cam = %CameraFocalPoint
	if cam:
		cam.global_translate(Vector3(midpoint.x, 0, midpoint.y))

func clear_island() -> void:
	var duration = 0.5
	var separation = 0.1
	# Tiles fall in reverse of the order they were created in
	_base_tiles.reverse()
	for tile in _base_tiles:
		var tween = (create_tween().set_trans(Tween.TRANS_CIRC)
				.set_ease(Tween.EASE_IN).set_parallel())
		tween.tween_property(tile, "position:y", -10, duration)
		var tile2 = _grid[tile.coordinates.x][tile.coordinates.y]
		if tile != tile2:
			tween.tween_property(tile2, "position:y", -10 + tile2.position.y, duration)
		tween.chain().tween_callback(func(): tile.queue_free())
		if tile != tile2:
			tween.tween_callback(func(): tile2.queue_free())
		await get_tree().create_timer(separation).timeout
	_base_tiles = []
	_grid = {}
	habitats = []
	await get_tree().create_timer(duration).timeout

func get_cell(pos : Vector2i) -> Tile:
	if pos.x not in _grid:
		return null
	if pos.y not in _grid[pos.x]:
		return null
	return _grid[pos.x][pos.y]

func get_neighbors(tile: Tile, include_empty_cells: bool = false) -> Array[Tile]:
	var neighbors: Array[Tile] = []
	for i in range(6):
		var pos = _axial_neighbor(tile.coordinates, i)
		var neighbor = get_cell(pos)
		if neighbor and (include_empty_cells or !neighbor.is_empty_slot):
			neighbors.append(neighbor)
		else:
			neighbors.append(null)
	return neighbors

func get_all_tiles(include_empty_cells: bool = false) -> Array[Tile]:
	var result : Array[Tile] = []
	for x in _grid:
		for y in _grid[x]:
			if include_empty_cells or !_grid[x][y].is_empty_slot:
				result.append(_grid[x][y])
	return result
	
func get_tiles_in_range(tile: Tile, range: int,
		include_empty_cells: bool = false, include_origin_tile: bool = false) -> Array[Tile]:
	var result: Array[Tile] = []
	for tile2 in get_all_tiles(include_empty_cells):
		if ((tile != tile2 or include_origin_tile)
				and _axial_distance(tile.coordinates, tile2.coordinates) <= range):
			result.append(tile2)
	return result

func _update_habitats() -> void:
	#print("Getting all habitats:")
	habitats = []
	for tile in get_all_tiles():
		#print("\tTile", tile.coordinates, ":")
		for i in range(2):
			var hab = tile.get_habitat(tile.data.terrain[i])
			#var string = ""
			#for tile2 in hab:
				#string += "({0},{1}), ".format([tile2.coordinates.x, tile2.coordinates.y])
			if not habitats.any(func(h): return h.tiles == hab and h.terrain == tile.data.terrain[i]):
				habitats.append(Habitat.new(tile.data.terrain[i], hab))
				#print("Tile habitat - {0}: ".format([Globals.TERRAIN[tile.data.terrain[i]].name_raw]),
						#string, "adding to array")
			#else:
				#print("Tile habitat - {0}: ".format([Globals.TERRAIN[tile.data.terrain[i]].name_raw]),
						#string, "already in array")

func _create_habitat_tile(data: TileData_) -> HabitatTile:
	var tile = _HABITAT_TILE_SCENE.instantiate()
	tile.hex_grid = self
	add_child(tile)
	tile.set_data(data)
	return tile

func _place_tile(object : Tile) -> void:
	if _current_tile:
		_current_tile.commit_placement()
		_grid[object.coordinates.x][object.coordinates.y] = _current_tile
		object.enable_colliders(false)
		#_print_grid()
		_current_tile.enable_colliders()
		if _placement_preview:
			score_changed.emit(_placement_preview.change)
			for preview in _placement_preview.tiles:
				preview.tile.animal_score[preview.animal_idx] += preview.total
			_clear_preview()
		tile_placed.emit(_current_tile)
		_current_tile = null
		_hovered_available_cell = null
		num_empty_cells -= 1

func _rotate_current_tile(steps_cw: int):
	if _hovered_available_cell and _current_tile:
		_current_tile.rotate_tile(steps_cw)
		_grid[_current_tile.coordinates.x][_current_tile.coordinates.y] = _hovered_available_cell
		_clear_preview()
		_grid[_current_tile.coordinates.x][_current_tile.coordinates.y] = _current_tile
		_preview_tile_placement(_current_tile)

func _preview_tile_placement(tile: HabitatTile) -> void:
	var neighbors = get_neighbors(tile)
	tile.preview_placement(neighbors)
	_placement_preview = TotalScoreChange.new()
	for tile_ in get_all_tiles():
		for i in range(2):
			var animal = tile_.data.animal[i]
			if animal:
				var score_change = animal.placement_preview(_placement_preview, tile_, tile, i)
	_update_habitats()
	for tile_ in _placement_preview.tiles:
		if tile_.total != 0:
			tile_.tile.show_score(tile_.animal_idx, tile_.total)
	score_previewed.emit(tile, _placement_preview)

func _clear_preview() -> void:
	score_preview_ended.emit()
	for tile in get_all_tiles():
		tile.clear_preview()
	if _current_tile:
		_current_tile.clear_preview()
	_placement_preview = null
	_update_habitats()
	
func _on_available_cell_mouse_entered(tile: Tile) -> void:
	if tile.is_in_group("Available Cells"):
		_hovered_available_cell = tile
		if _current_tile:
			_current_tile.position = tile.position
			_current_tile.coordinates = tile.coordinates
			_current_tile.show_()
			_grid[tile.coordinates.x][tile.coordinates.y] = _current_tile
			_preview_tile_placement(_current_tile)

func _on_available_cell_mouse_exited(tile: Tile) -> void:
	_hovered_available_cell = null
	if _current_tile:
		_current_tile.hide_()
		_grid[tile.coordinates.x][tile.coordinates.y] = tile
		_clear_preview()
		#_autotile_neighbors(tile)

func _on_available_cell_input_event(tile: Tile, event: InputEvent) -> void:
	if (event is InputEventMouseButton
			and !event.pressed
			and _hovered_available_cell == tile):
		if event.button_index == MOUSE_BUTTON_LEFT:
			_place_tile(tile)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_rotate_current_tile(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_rotate_current_tile(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_rotate_current_tile(5)

#func _autotile_tile(tile) -> void:
	#var neighbors = get_neighbors(tile)
	#tile.autotile(neighbors)
#
#func _autotile_neighbors(tile) -> void:
	#for neighbor in get_neighbors(tile):
		#if neighbor:
			#_autotile_tile(neighbor)

###
# HELPER FUNCTIONS
###
func _axial_direction(direction : int) -> Vector2i:
	return AXIAL_DIRECTION_VECTORS[direction]
	
func _axial_neighbor(pos : Vector2i, direction : int) -> Vector2i:
	return pos + _axial_direction(direction)
	
func _axial_to_world(pos : Vector2i) -> Vector3:
	var pos_x = Globals.CELL_SIZE * 1.5 * pos.x
	var pos_y = Globals.CELL_SIZE * (sqrt(3) / 2.0 * pos.x + sqrt(3) * pos.y)
	return Vector3(pos_x, 0, pos_y)
	
func _axial_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	var vec = pos1 - pos2
	return (abs(vec.x)
			+ abs(vec.x + vec.y)
			+ abs(vec.y)) / 2

func _print_grid() -> void:
	for x in _grid:
		var string = str(x) + " || "
		for y in _grid[x]:
			if not _grid[x][y].is_empty_slot:
				string += str(_grid[x][y].coordinates) + ", "
		print(string)
