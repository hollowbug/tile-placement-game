extends Object
class_name Items

static var ITEMS: Array[ItemData] = []

static func _static_init():
	var dirname = "res://Scripts/Items"
	var files = Globals.list_files_in_folder(dirname)
	for fname in files:
		if fname.ends_with(".gd") or fname.ends_with(".gdc"):
			var item = load(dirname.path_join(fname)).new(-1)
			if item.exclude == false:
				ITEMS.append(item)
				print("Loading item: ", item.name)

static func get_item(name: String) -> ItemData:
	for item in ITEMS:
		if item.name == name:
			return item.get_script().new(-1)
	print("Item not found: ", name)
	return null
