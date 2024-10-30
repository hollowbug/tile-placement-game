extends Resource
class_name Animal

# if exclude is true, this animal will be excluded when the application starts
var exclude : bool = true
var name : String
var name_plural : String
var sprite : Resource
var categories : Array[int]
var habitats : Array[int]
var rarity : int
var description : String
var function : Callable

func get_description() -> String:
	var result = description.replace("<name>", name)
	result = result.replace("<name_plural>", name_plural)
	result = Globals.format_string(result)
	return result
	
func get_category_string() -> String:
	var strings = []
	for categ in categories:
		strings.append(Globals.ANIMAL_CATEGORY[categ].string)
	return "/".join(strings)

func has_category(category: int) -> bool:
	return category in categories
