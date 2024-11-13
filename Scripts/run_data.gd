extends Resource
class_name RunData

static var DECK_TYPE = {
	default = [
		TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.GRASS, Globals.get_animal("Hummingbird"), Globals.get_animal("Hummingbird")),
		TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.WATER, Globals.get_animal("Hummingbird"), Globals.get_animal("Hummingbird")),
		TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.WATER, Globals.get_animal("Hummingbird"), Globals.get_animal("Hummingbird")),
		TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.WATER, Globals.get_animal("Crocodile")),
		TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.JUNGLE, Globals.get_animal("Crocodile")),
		TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.DESERT, Globals.get_animal("Crocodile")),
		TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.GRASS, Globals.get_animal("Kingsnake")),
		TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.FOREST1, Globals.get_animal("Kingsnake")),
		TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.JUNGLE, Globals.get_animal("Kingsnake")),
		TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.FOREST1, Globals.get_animal("King Cobra")),
		TileData_.new(Globals.TERRAIN_TYPE.FOREST1, Globals.TERRAIN_TYPE.GRASS, Globals.get_animal("King Cobra")),
		TileData_.new(Globals.TERRAIN_TYPE.FOREST1, Globals.TERRAIN_TYPE.DESERT, Globals.get_animal("King Cobra")),
	] as Array[TileData_],
	#default = [
		#TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.GRASS),
		#TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.WATER),
		#TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.WATER),
		#TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.WATER, Globals.get_animal("Duck")),
		#TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.JUNGLE, Globals.get_animal("Duck")),
		#TileData_.new(Globals.TERRAIN_TYPE.WATER, Globals.TERRAIN_TYPE.DESERT, Globals.get_animal("Duck")),
		#TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.GRASS, Globals.get_animal("Kangaroo")),
		#TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.FOREST1, Globals.get_animal("Kangaroo")),
		#TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.JUNGLE, Globals.get_animal("Kangaroo")),
		#TileData_.new(Globals.TERRAIN_TYPE.GRASS, Globals.TERRAIN_TYPE.FOREST1, Globals.get_animal("Mouse")),
		#TileData_.new(Globals.TERRAIN_TYPE.FOREST1, Globals.TERRAIN_TYPE.GRASS, Globals.get_animal("Mouse")),
		#TileData_.new(Globals.TERRAIN_TYPE.FOREST1, Globals.TERRAIN_TYPE.DESERT, Globals.get_animal("Mouse")),
	#] as Array[TileData_],
}

static var BOSSES: Array[String] = ["Volcano"]

var deck : Array[TileData_]
var items : Array[ItemData]
var island : int
var hand_size : int
var refresh_cost : int
var required_score : int
var current_boss : String
var _remaining_bosses : Array[String]
var item_costs : Array[int]
var _animal_rarity_weights : Array[int]
var _item_rarity_weights : Array[int]
var _animals_weighted : Array[Animal]
#var _animals_weighted : Dictionary
var _items_weighted : Array[ItemData]

func _init(deck_: String):
	deck = []
	for tile in DECK_TYPE[deck_]:
		deck.append(tile.copy())
	# can no longer have starting items because the game hangs
	items = [
		#Items.get_item("Money Tree"),
		#Items.get_item("Grass"),
	]
	island = 4
	hand_size = 3
	refresh_cost = 5
	_remaining_bosses = BOSSES.duplicate()
	_animal_rarity_weights = [50, 12, 4, 1]
	update_animal_rarity_weights()
	_item_rarity_weights = [50, 12, 4, 1]
	update_item_rarity_weights()
	item_costs = [10, 20, 30, 50]

func next_island() -> void:
	island += 1
	required_score = 14 + island * 2
	#required_score = 1
	if island % 5 == 0:
		if _remaining_bosses.is_empty():
			_remaining_bosses = BOSSES.duplicate()
		current_boss = BOSSES.pick_random()
		_remaining_bosses.erase(current_boss)
	else:
		current_boss = ""

func get_random_tile(max_animals: int = 2) -> Dictionary:
	var cost = 2
	var type = [
		randi() % Globals.TERRAIN_TYPE.size(),
		randi() % Globals.TERRAIN_TYPE.size()
	]
	var animal_ = [null, null]
	if max_animals > 0 and randf() < 0.7: # 70% chance of first animal
		if type[0] != type[1]:
			animal_[0] = get_random_animal(type[0])
			cost += Globals.ANIMAL_RARITY_COSTS[animal_[0].rarity]
			if max_animals > 1 and randf() < 0.1: # 10% chance of second animal
				animal_[1] = get_random_animal(type[1])
				cost += Globals.ANIMAL_RARITY_COSTS[animal_[1].rarity]
				
		else:
			animal_[0] = get_random_animal(type[0])
			cost += Globals.ANIMAL_RARITY_COSTS[animal_[0].rarity]
	return {
		tile = TileData_.new(type[0], type[1], animal_[0], animal_[1]),
		cost = cost
	}

func get_random_animal(terrain: int = -1, category: int = -1) -> Animal:
	var arr = _animals_weighted
	if terrain != -1:
		arr = arr.filter(func(a): return (terrain in a.habitats or a.name == "Chameleon"))
	if category != -1:
		arr = arr.filter(func(a): return category in a.categories)
	return arr.pick_random()

func get_random_item() -> Dictionary:
	var item: ItemData
	# If player already has all items, returns a random duplicate
	if _items_weighted.is_empty():
		update_item_rarity_weights()
		item = _items_weighted.pick_random().get_script().new(-1)
		_items_weighted.clear()
	else:
		item = _items_weighted.pick_random().get_script().new(-1)
	return {
		item = item,
		cost = item_costs[item.rarity],
	}

func get_shop_items() -> Array[Dictionary]:
	# Returns 3 different random items that the player doesn't have yet
	var result = [] as Array[Dictionary]
	var arr = _items_weighted.duplicate()
	for i in range(3):
		if arr.is_empty():
			break
		var item = arr.pick_random().get_script().new(-1)
		arr = arr.filter(func(x): return x.name != item.name)
		result.append({
			item = item,
			cost = item_costs[item.rarity],
		})
	return result

func add_item(item: ItemData) -> void:
	items.append(item)
	# When an item is gained, it's removed from the array
	# # so the player can't get multiple copies of an item
	_items_weighted = _items_weighted.filter(func(i): return i.name != item.name)

func update_animal_rarity_weights() -> void:
	#_animals_weighted = {}
	_animals_weighted = []
	for animal in Globals.ANIMAL:
		for i in range(_animal_rarity_weights[animal.rarity]):
			_animals_weighted.append(animal)
	#for terrain in Globals.TERRAIN_TYPE.values():
		#var arr = []
		#for animal in Globals.TERRAIN[terrain].animals:
			#for i in range(_animal_rarity_weights[animal.rarity]):
				#arr.append(animal)
		#_animals_weighted[terrain] = arr

func update_item_rarity_weights() -> void:
	_items_weighted = []
	for item in Items.ITEMS:
		for i in range(_item_rarity_weights[item.rarity]):
			_items_weighted.append(item)
