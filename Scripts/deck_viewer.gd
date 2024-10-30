extends PanelContainer

signal closed

@export_enum("Remaining", "All") var mode := "Remaining":
	set(value):
		mode = value
		if is_inside_tree():
			_update()

var island_mode := true:
	set(value):
		island_mode = value
		%IslandModeButtons.visible = value
		if mode == "Remaining":
			_update()

var _TILE_CONTROL = preload("res://Scenes/tile_control.tscn")
var _full_deck : Array[TileData_]
var _remaining_deck : Array[TileData_]
var _tiles : Array[TileControl]
var _used_tiles : Array[TileControl]
@onready var _button_remaining = %ButtonRemaining
@onready var _button_all = %ButtonAll
@onready var _tile_container = %TileContainer

func set_deck(deck : Array[TileData_]) -> void:
	_full_deck = deck
	for tile in _tiles:
		tile.queue_free()
	_tiles = []
	_used_tiles = []
	for data in deck:
		#for i in range(10):
			add_tile(data)

func update_remaining_tiles(remaining_deck: Array[TileData_]) -> void:
	_used_tiles = []
	_remaining_deck = remaining_deck
	for tile in _tiles:
		if not remaining_deck.any(func(x): return x.id == tile.data.id):
			_used_tiles.append(tile)
	if mode == "Remaining":
		_update()

func add_tile(data: TileData_) -> TileControl:
	var tile = _TILE_CONTROL.instantiate()
	tile.selectable = false
	_tiles.append(tile)
	_tile_container.add_child(tile)
	tile.set_data(data)
	return tile

func _update() -> void:
	if !island_mode or mode == "All":
		for i in range(_tiles.size()):
			_tile_container.move_child(_tiles[i], i)
			_tiles[i].get_node("Tile").modulate.a = 1
	else:
		var i = 0
		for tile in _tiles:
			if tile not in _used_tiles:
				tile.get_node("Tile").modulate.a = 1
				_tile_container.move_child(tile, i)
				i += 1
		for tile in _used_tiles:
			tile.get_node("Tile").modulate.a = 0.3
			_tile_container.move_child(tile, i)
			i += 1

func _on_button_remaining_toggled(toggled_on):
	if toggled_on:
		_button_all.button_pressed = false
		mode = "Remaining"
	elif not _button_all.button_pressed:
		_button_remaining.button_pressed = true

func _on_button_all_toggled(toggled_on):
	if toggled_on:
		_button_remaining.button_pressed = false
		mode = "All"
	elif not _button_remaining.button_pressed:
		_button_all.button_pressed = true

func _on_button_close_pressed():
	closed.emit()
