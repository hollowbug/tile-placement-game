extends Resource
class_name ItemData

static var max_id = 0

var exclude : bool = true
var id : int
var name : String
var rarity : int
var sprite : Resource

func _init(id_):
	if id_ == -1:
		id = max_id
		max_id += 1
	else:
		id = id

#func copy(keep_id: bool = true):
	#var id_ = id if keep_id else -1
	#var item = ItemData.new(id_)
	#item.name = name
	#item.rarity = rarity
	#item.sprite = sprite
	#return item

# =================================================
# THESE FUNCTIONS ARE OVERRIDDEN IN INHERITED ITEMS
func get_description() -> String:
	return "No description available."

func on_island_started(_item: Item, _hex_grid: HexGrid, _changes: Changes) -> void:
	pass

func on_placement_previewed(_item: Item, _tile: HabitatTile, _changes: Changes) -> void:
	pass

func on_tile_placed(_item: Item, _tile: HabitatTile, _changes: Changes) -> void:
	pass

func on_shop_entered(_item: Item, _changes: Changes) -> void:
	pass
