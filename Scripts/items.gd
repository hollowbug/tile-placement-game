extends Object
class_name Items

static var ITEMS: Array[ItemData] = []

static func _static_init():
	var dirname = "res://Scripts/Items"
	var files = Globals.list_files_in_folder(dirname)
	for fname in files:
		var item = load(dirname.path_join(fname)).new()
		if item.exclude == false:
			ITEMS.append(item)

static func get_item(name: String) -> ItemData:
	for item in ITEMS:
		if item.name == name:
			return item.duplicate(true)
	print("Item not found: ", name)
	return null
