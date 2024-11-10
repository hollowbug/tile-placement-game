extends Node3D

var _TILE_CONTROL = preload("res://Scenes/tile_control.tscn")
var _SHOP_ITEM = preload("res://Scenes/shop_item.tscn")
var _ITEM = preload("res://Scenes/item.tscn")

var _state : String:
	set(value):
		_state = value
		#if value == "island":
			#_island_panel.modulate.a = 1.0
		#else:
			#_island_panel.modulate.a = 0.0
		_deck_viewer.island_mode = value == "island"

var _money := 0:
	set(value):
		if value == _money:
			return
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
var _shuffled_deck : Array[TileData_]
var _items : Array[Item]
var _hand_tiles : Array[TileControl] = []
var _hovered_hand_tile : TileControl
var _selected_hand_tile : TileControl
var _shop_tiles : Array[Control]
var _shop_items : Array[Control]

@onready var _canvas_layer := $HUD
@onready var _hex_grid := $HexGrid
#@onready var _island_panel = %IslandPanel
@onready var _score_preview := %ScorePreview
@onready var _hand := %HandTiles
@onready var _deck_button := %Deck
@onready var _deck_viewer := %DeckViewer
@onready var _money_node := %Money
@onready var _item_container := %Items
@onready var _slide_in_panel := %SlideInPanel
@onready var _labels := {
	island = %LabelIsland,
	score_text = %LabelScoreText,
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
	_run.next_island()
	#_next_island()
	_money = 250
	_enter_shop()

func _next_island() -> void:
	_score = 0
	_update_score()
	var num_starting_tiles = randi_range(2, 5)
	var starting_tiles: Array[TileData_] = []
	for i in range(num_starting_tiles):
		starting_tiles.append(_run.get_random_tile(0).tile)
	_hex_grid.create_island(10, starting_tiles)
	# Duplicate run deck so temporary changes can be made to it
	_deck = []
	for tile in _run.deck:
		_deck.append(tile.copy())
	_deck_viewer.set_deck(_deck)
	_update_deck_size()
	_shuffled_deck = _deck.duplicate()
	_shuffled_deck.shuffle()
	for tile in _hand_tiles:
		tile.queue_free()
	_hand_tiles = []
	_state = "island"
	_waiting = true
	await get_tree().create_timer(0.5).timeout
	var change = Changes.new()
	for item in _items:
		item.data.on_island_started(item, _hex_grid, change)
	for item in change.items:
		_score += item.score_change
		_update_score()
		await item.item.show_score(item, false)
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
	if _shuffled_deck.is_empty():
		return
	var tile = _TILE_CONTROL.instantiate()
	tile.position = _deck_button.global_position - _hand.global_position
	_hand.add_child(tile)
	_hand_tiles.append(tile)
	tile.mouse_entered.connect(_on_hand_tile_mouse_entered.bind(tile))
	tile.mouse_exited.connect(_on_hand_tile_mouse_exited.bind(tile))
	tile.control_selected.connect(_on_hand_tile_selected.bind(tile))
	tile.control_unselected.connect(_on_hand_tile_unselected.bind(tile))
	tile.set_data(_shuffled_deck.pop_front())
	tile.scale = Vector2()
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(tile, "scale", Vector2.ONE, 0.3)
	_update_deck_size()

func _unselect_tile() -> void:
	_selected_hand_tile = null
	_hex_grid.set_current_tile(null)

func _show_score_preview(changes: Changes) -> void:
	_score_preview.visible = true
	if changes.score_change > 0:
		_score_preview.self_modulate = Color.GREEN
	elif changes.score_change < 0:
		_score_preview.self_modulate = Color.RED
	else:
		_score_preview.self_modulate = Color.WHITE
	var string = "+" + str(changes.score_change) if changes.score_change > -1 else str(changes.score_change)
	_labels.score_preview.set_text(string)
	if changes.money_change != 0:
		string = "+" + str(changes.money_change) if changes.money_change > -1 else str(changes.money_change)
		_labels.money.set_text("${0} {1}".format([str(_money), string]))

func _update_score() -> void:
	_labels.score.set_text(str(_score) + "/" + str(_run.required_score))

func _update_deck_size() -> void:
	if _state == "island":
		_labels.deck_size.set_text(str(_shuffled_deck.size()))
	else:
		_labels.deck_size.set_text(str(_deck.size()))

func _enter_shop() -> void:
	_state = "shop"
	_update_deck_size()
	_deck_viewer.set_deck(_run.deck)
	_shop_nodes.shop.visible = true
	_refresh_shop()
	var item_changes = Changes.new()
	for item in _items:
		item.data.on_shop_entered(item, item_changes)
	for item in item_changes.items:
		_money += item.money_change
		item.item.pop_effect()
		await get_tree().create_timer(0.5).timeout
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
	random_items.sort_custom(func(a,b): return a.cost < b.cost)
	for i in range(3):
		if random_items.size() <= i:
			break
		var shop_item = _SHOP_ITEM.instantiate()
		var item = _ITEM.instantiate()
		_shop_items.append(shop_item)
		_shop_nodes.items.add_child(shop_item)
		shop_item.set_item(item, random_items[i].cost)
		item.set_data(random_items[i].item)
		shop_item.button.pressed.connect(_on_shop_item_button_pressed.bind(shop_item, item))
	
	_update_buy_buttons()

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
	_run.add_item(item)

func _add_item_from_shop(item: Item) -> void:
	_items.append(item)
	_run.add_item(item.data)
	var placeholder = _ITEM.instantiate()
	placeholder.modulate.a = 0
	_item_container.add_child(placeholder)
	var pos = item.global_position
	item.get_parent().remove_child(item)
	_canvas_layer.add_child(item)
	item.global_position = pos
	# Wait for item container to position new child
	await get_tree().process_frame
	pos = placeholder.global_position
	placeholder.queue_free()
	var tween = create_tween().set_parallel()
	tween.tween_property(item, "global_position", pos, 0.1)
	await tween.finished
	await get_tree().process_frame
	_canvas_layer.remove_child(item)
	_item_container.add_child(item)
	item.global_position = pos

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
	if _waiting:
		for tile2 in _hand_tiles:
			tile2.unselect()
		return
	
	_selected_hand_tile = tile
	_hex_grid.set_current_tile(tile.data)
	for tile2 in _hand_tiles:
		if tile != tile2:
			tile2.unselect()

func _on_hand_tile_unselected(tile: TileControl) -> void:
	if _selected_hand_tile == tile:
		_selected_hand_tile = null
		_hex_grid.unset_current_tile()

func _on_hex_grid_tile_placed(tile: HabitatTile, changes: Changes) -> void:
	_hand_tiles.erase(_selected_hand_tile)
	_selected_hand_tile.queue_free()
	_selected_hand_tile = null
	_waiting = true
	_score += changes.score_change
	_update_score()
	_money += changes.money_change
	
	var tiles = _hex_grid.get_all_tiles()
	var new_animals = false
	for tile2 in tiles:
		for i in range(2):
			var animal = tile2.data.animal[i]
			if animal:
				animal.on_tile_placed(tile2, tile, i)
				# Handle added random animals
				if animal is RandomAnimal:
					new_animals = true
					var new_animal = _run.get_random_animal(animal.terrain, animal.category)
					tile2.preview_animals[i] = new_animal
					tile2.commit_animal_preview()
					tile2.update_animal(i)
					for tile3 in _deck:
						if tile3.id == tile2.data.id:
							tile3.animal[i] = new_animal
					if animal.permanent:
						for tile3 in _run.deck:
							if tile3.id == tile2.data.id:
								tile3.animal[i] = new_animal
	
	# If animals were added, update scores
	if new_animals:
		var new_changes = Changes.new()
		for tile2 in tiles:
			for i in range(2):
				if tile2.data.animal[i]:
					tile2.data.animal[i].calculate_score(new_changes, tile2, null, i)
		for tile2 in new_changes.tiles:
			tile2.tile.show_animal_preview(tile2)
		_show_score_preview(new_changes)
		await get_tree().create_timer(1.0).timeout
		for tile2 in new_changes.tiles:
			tile2.tile.clear_preview()
		_score_preview.visible = false
		_score += new_changes.score_change
		_update_score()
		for tile2 in new_changes.tiles:
			tile2.tile.animal_score[tile2.animal_idx] += tile2.score_change
	
	await get_tree().create_timer(0.2).timeout
	var item_changes = Changes.new()
	for item in _items:
		item.data.on_tile_placed(item, tile, item_changes)
	for item in item_changes.items:
		_score += item.score_change
		_money += item.money_change
		_update_score()
		await item.item.show_score(item.score_change, false)
	_deck_viewer.set_deck(_deck)
	_waiting = false
	_draw_tile()
	# Check for end of island
	if _hex_grid.num_empty_cells <= 0 or _hand_tiles.is_empty():
		_waiting = true
		await get_tree().create_timer(0.2).timeout
		await _hex_grid.clear_island()
		_display_summary()

func _on_hex_grid_score_previewed(tile: HabitatTile, change: Changes):
	for item in _items:
		item.data.on_placement_previewed(item, tile, change)
	for item in change.items:
		item.item.show_score(item)
	_show_score_preview(change)

func _on_hex_grid_score_preview_ended():
	_score_preview.visible = false
	_labels.money.set_text("$" + str(_money))
	for item in _items:
		item.hide_score()

#func _on_hex_grid_score_changed(change):
	#_score += change
	#_labels.score.set_text(str(_score) + "/" + str(_run.required_score))

func _on_deck_clicked():
	#if _waiting:
		#return
	if _state == "island":
		_deck_viewer.update_remaining_tiles(_shuffled_deck)
	_deck_viewer.visible = true
	#_deck_button.visible = false
	_viewing_deck = true

func _on_deck_viewer_closed():
	_deck_viewer.visible = false
	_viewing_deck = false
	#_deck_button.visible = true

func _on_summary_closed():
	%SummaryPanel.visible = false
	if _score >= _run.required_score:
		_money += _money_earned
		_run.next_island()
		_labels.island.set_text("Island " + str(_run.island))
		_labels.score_text.set_text("Required score:")
		_labels.score.set_text(str(_run.required_score))
		_enter_shop()
	else:
		get_tree().reload_current_scene()

func _on_shop_item_button_pressed(shop_item: Node, item: Control) -> void:
	if _money >= shop_item.cost:
		_money -= shop_item.cost
		if item is TileControl:
			_add_tile_to_deck(item)
		else:
			_add_item_from_shop(item)
		shop_item.set_empty()

func _on_shop_button_refresh_pressed() -> void:
	if _money >= _run.refresh_cost:
		_refresh_shop()
		_money -= _run.refresh_cost

func _on_shop_button_continue_pressed() -> void:
	_slide_in_panel.visible = false
	_labels.score_text.set_text("Score")
	_next_island()
