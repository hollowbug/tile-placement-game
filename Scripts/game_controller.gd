extends Node3D

var _TILE_CONTROL = preload("res://Scenes/tile_control.tscn")
var _SHOP_ITEM = preload("res://Scenes/shop_item.tscn")
var _ITEM = preload("res://Scenes/item.tscn")

var _state : String:
	set(value):
		_state = value
		if value == "island":
			_island_panel.modulate.a = 1.0
		else:
			_island_panel.modulate.a = 0.0
		_deck_viewer.island_mode = value == "island"

var _money := 100:
	set(value):
		_money = value
		_money_node.pop_effect()
		_labels.money.set_text("$" + str(value))
		if _state == "shop":
			_update_buy_buttons()

var _waiting := false
var _viewing_deck := false
var _score : int
#var _displayed_score : int
var _money_earned : int
var _run : RunData
var _deck : Array[TileData_]
var _current_deck : Array[TileData_]
var _items : Array[Item]
var _hand_tiles : Array[TileControl] = []
var _hovered_hand_tile : TileControl
var _selected_hand_tile : TileControl
var _shop_tiles : Array[Control]
var _shop_items : Array[Control]

@onready var _canvas_layer := $HUD
@onready var _hex_grid := $HexGrid
@onready var _island_panel = %IslandPanel
@onready var _score_preview := %ScorePreview
@onready var _hand := %HandTiles
@onready var _deck_button := %Deck
@onready var _deck_viewer := %DeckViewer
@onready var _money_node := %Money
@onready var _item_container := %Items
@onready var _slide_in_panel := %SlideInPanel
@onready var _labels := {
	score = %LabelScore,
	score_preview = %LabelScorePreview,
	deck_size = %LabelDeckSize,
	money = %LabelMoney
}
@onready var _shop_nodes := {
	shop = %Shop,
	tiles = %Shop/%Tiles/%FlowContainer,
	items = %Shop/%Items/%FlowContainer,
	refresh = %Shop/%ButtonRefresh
}

func _ready():
	%Shop/%ButtonRefresh.pressed.connect(_on_shop_button_refresh_pressed)
	%Shop/%ButtonContinue.pressed.connect(_on_shop_button_continue_pressed)
	_run = RunData.new("default")
	for item in _run.items:
		if item:
			_add_item(item)
		else:
			print("Error creating starting item")
	#_next_island()
	_enter_shop()
	
func _next_island() -> void:
	_run.next_island()
	_score = 0
	_update_score()
	var num_starting_tiles = randi_range(2, 5)
	var starting_tiles: Array[TileData_] = []
	for i in range(num_starting_tiles):
		starting_tiles.append(_run.get_random_tile(0).tile)
	_hex_grid.create_island(4, starting_tiles)
	# Duplicate run deck so temporary changes can be made to it
	_deck = []
	_current_deck = []
	for tile in _run.deck:
		_deck.append(tile.copy())
		_current_deck.append(tile.copy())
	_deck_viewer.set_deck(_deck)
	_update_deck_size()
	_current_deck.shuffle()
	for tile in _hand_tiles:
		tile.queue_free()
	_hand_tiles = []
	_state = "island"
	_waiting = true
	await get_tree().create_timer(0.5).timeout
	var change = TotalScoreChange.new()
	for item in _items:
		item.data.on_island_started(item, _hex_grid, change)
	for item in change.items:
		_score += item.total
		_update_score()
		await item.item.show_score(item.total, false)
	_waiting = false
	for i in range(_run.hand_size):
		_draw_tile()
		await get_tree().create_timer(0.1).timeout

#func _input(event):
	#if _waiting:
		#get_viewport().set_input_as_handled()

func _unhandled_key_input(event):
	if event.keycode == KEY_1 and event.pressed:
		_draw_tile()
	#if event.keycode == KEY_TAB and event.pressed:
		#_randomize_tile_options()
	elif event.keycode == KEY_SPACE and event.pressed:
		get_tree().reload_current_scene()
	elif event.keycode == KEY_ESCAPE and event.pressed and _viewing_deck:
		_on_deck_viewer_closed()

func _draw_tile() -> void:
	if _current_deck.is_empty():
		return
	var tile = _TILE_CONTROL.instantiate()
	tile.size = Vector2()
	_hand.add_child(tile)
	_hand_tiles.append(tile)
	tile.mouse_entered.connect(_on_hand_tile_mouse_entered.bind(tile))
	tile.mouse_exited.connect(_on_hand_tile_mouse_exited.bind(tile))
	tile.control_selected.connect(_on_hand_tile_selected.bind(tile))
	tile.control_unselected.connect(_on_hand_tile_unselected.bind(tile))
	tile.set_data(_current_deck.pop_front())
	tile.global_position = _deck_button.global_position
	tile.scale = Vector2()
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(tile, "scale", Vector2.ONE, 0.3)
	_update_deck_size()

func _unselect_tile() -> void:
	_selected_hand_tile = null
	_hex_grid.set_current_tile(null)

func _update_score() -> void:
	_labels.score.set_text(str(_score) + "/" + str(_run.required_score))

func _update_deck_size() -> void:
	if _state == "island":
		_labels.deck_size.set_text(str(_current_deck.size()))
	else:
		_labels.deck_size.set_text(str(_deck.size()))

func _enter_shop() -> void:
	_state = "shop"
	_update_deck_size()
	_deck_viewer.set_deck(_run.deck)
	_shop_nodes.shop.visible = true
	_refresh_shop()
	await _slide_in_panel.slide_in()
	_waiting = false

func _refresh_shop() -> void:
	# Tiles
	for tile in _shop_tiles:
		tile.queue_free()
	_shop_tiles = []
	var random_tiles = []
	for i in range(3):
		random_tiles.append(_run.get_random_tile())
	random_tiles.sort_custom(func(a,b): return a.cost < b.cost)
	for i in range(3):
		var shop_item = _SHOP_ITEM.instantiate()
		var tile = _TILE_CONTROL.instantiate()
		_shop_tiles.append(shop_item)
		_shop_nodes.tiles.add_child(shop_item)
		shop_item.set_item(tile, random_tiles[i].cost)
		tile.set_data(random_tiles[i].tile)
		shop_item.button.pressed.connect(_on_shop_item_button_pressed.bind(shop_item, tile))
	
	# Items
	for item in _shop_items:
		item.queue_free()
	_shop_items = []
	var random_items = _run.get_shop_items()
	for i in range(3):
		var shop_item = _SHOP_ITEM.instantiate()
		var item = _ITEM.instantiate()
		_shop_items.append(shop_item)
		_shop_nodes.items.add_child(shop_item)
		shop_item.set_item(item, random_items[i].cost)
		item.set_data(random_items[i].item)
		shop_item.button.pressed.connect(_on_shop_item_button_pressed.bind(shop_item, item))

#func _randomize_tile_options() -> void:
	#_hand_tiles_data = []
	#for tile in _hand_tiles_data:
		#var data = TileData_.random(2)
		#tile.set_data(data)

func _add_tile_to_deck(tile: TileControl, temporary: bool = false) -> void:
	_deck.push_back(tile.data)
	if !temporary:
		_run.deck.push_back(tile.data)
	_deck_viewer.add_tile(tile.data)
	var pos = tile.global_position
	tile.get_parent().remove_child(tile)
	_canvas_layer.add_child(tile)
	tile.global_position = pos
	tile.z_index = 50
	var tween = create_tween().set_parallel()
	#var visual_tile = tile.get_node("Tile")
	tween.tween_property(tile, "global_position", _deck_button.global_position, 0.1)
	tween.tween_property(tile, "scale", Vector2(), 0.1)
	await tween.finished
	tile.queue_free()
	_update_deck_size()
	_deck_button.pop_effect()

func _add_item(item: ItemData) -> void:
	var node = _ITEM.instantiate()
	_item_container.add_child(node)
	node.set_data(item)
	_items.append(node)

func _display_summary() -> void:
	var container = %SummaryPanel/VBoxContainer
	
	var button = container.get_node("HBoxContainer/Button")
	
	if _score >= _run.required_score:
		button.modulate.a = 0
		button.disabled = true
		_money_earned = 5
		var stack = [container.get_node("Rewards/Base/Control")]
		container.get_node("Title").set_text("Island Complete")
		container.get_node("Rewards").visible = true
		if _score >= _run.required_score * 2:
			var bonus = min(5, floor(_score / _run.required_score))
			_money_earned += bonus
			stack.append(container.get_node("Rewards/ScoreBonus/Control"))
			container.get_node("Rewards/ScoreBonus").visible = true
			container.get_node("Rewards/ScoreBonus/Control/Label2").set_text("$" + str(bonus))
		stack.append(container.get_node("Rewards/Total/Control"))
		container.get_node("Rewards/Total/Control/Label").set_text("Total $" + str(_money_earned))
		for node in stack:
			node.modulate.a = 0
			node.scale = Vector2(2, 2)
		await %SummaryPanel.slide_in()
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		for node in stack:
			tween.tween_callback((func(x): x.modulate.a = 1).bind(node))
			tween.tween_property(node, "scale", Vector2.ONE, 0.1)
			tween.tween_method(func(_x): pass, 0, 0, 0.2)
		await tween.finished
		button.modulate.a = 1
		button.disabled = false
	else:
		%SummaryPanel.slide_in()
		container.get_node("Title").set_text("Game Over")
		container.get_node("Rewards").visible = false

func _update_buy_buttons() -> void:
	for item in _shop_tiles + _shop_items:
		item.set_can_afford(_money)
	if _money >= _run.refresh_cost:
		_shop_nodes.refresh.modulate = Color.WHITE
	else:
		_shop_nodes.refresh.modulate = Color.RED

func _on_hand_tile_mouse_entered(tile: TileControl) -> void:
	_hovered_hand_tile = tile
	
func _on_hand_tile_mouse_exited(tile: TileControl) -> void:
	if _hovered_hand_tile == tile:
		_hovered_hand_tile = null

func _on_hand_tile_selected(tile: TileControl) -> void:
	_selected_hand_tile = tile
	_hex_grid.set_current_tile(tile.data)
	for tile2 in _hand_tiles:
		if tile != tile2:
			tile2.unselect()

func _on_hand_tile_unselected(tile: TileControl) -> void:
	if _selected_hand_tile == tile:
		_selected_hand_tile = null

func _on_hex_grid_tile_placed(tile: HabitatTile) -> void:
	_hand_tiles.erase(_selected_hand_tile)
	_selected_hand_tile.queue_free()
	_selected_hand_tile = null
	_waiting = true
	await get_tree().create_timer(0.2).timeout
	var change = TotalScoreChange.new()
	for item in _items:
		item.data.on_tile_placed(item, tile, change)
	for item in change.items:
		_score += item.total
		_update_score()
		await item.item.show_score(item.total, false)
	_waiting = false
	_draw_tile()
	if _hex_grid.num_empty_cells <= 0 or _hand_tiles.is_empty():
		_waiting = true
		#await get_tree().create_timer(0.4).timeout
		await _hex_grid.clear_island()
		_display_summary()

func _on_hex_grid_score_previewed(tile: HabitatTile, change: TotalScoreChange):
	_score_preview.visible = true
	for item in _items:
		item.data.on_placement_previewed(item, tile, change)
	for item in change.items:
		item.item.show_score(item.total)
	if change.change > 0:
		_score_preview.self_modulate = Color.GREEN
	elif change.change < 0:
		_score_preview.self_modulate = Color.RED
	else:
		_score_preview.self_modulate = Color.WHITE
	var string = "+" + str(change.change) if change.change > -1 else str(change.change)
	_labels.score_preview.set_text(string)
	
func _on_hex_grid_score_preview_ended():
	_score_preview.visible = false
	for item in _items:
		item.hide_score()

func _on_hex_grid_score_changed(change):
	_score += change
	_labels.score.set_text(str(_score) + "/" + str(_run.required_score))

func _on_deck_clicked():
	if _waiting:
		return
	if _state == "island":
		_deck_viewer.update_remaining_tiles(_current_deck)
	_deck_viewer.visible = true
	_deck_button.visible = false
	_viewing_deck = true

func _on_deck_viewer_closed():
	_deck_viewer.visible = false
	_viewing_deck = false
	_deck_button.visible = true

func _on_summary_closed():
	%SummaryPanel.visible = false
	if _score >= _run.required_score:
		_money += _money_earned
		_enter_shop()
	else:
		get_tree().reload_current_scene()

func _on_shop_item_button_pressed(shop_item: Node, item: Control) -> void:
	if _money >= shop_item.cost:
		_money -= shop_item.cost
		if item is TileControl:
			_add_tile_to_deck(item)
		shop_item.set_empty()

func _on_shop_button_refresh_pressed() -> void:
	if _money >= _run.refresh_cost:
		_refresh_shop()
		_money -= _run.refresh_cost
	
func _on_shop_button_continue_pressed() -> void:
	_slide_in_panel.visible = false
	_next_island()