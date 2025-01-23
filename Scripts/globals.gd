extends Node

const CELL_SIZE := 1.0 / sqrt(3)
enum TERRAIN_TYPE {GRASS, WATER, FOREST1, JUNGLE, DESERT}
enum SPECIAL_TERRAIN_TYPE {
	VOLCANO = 100,
	ROCK = 101,
}
enum ANIMAL_TYPE {BIRD, HERBIVORE, PREDATOR, REPTILE, RODENT}
var ANIMAL: Array[Animal] = []
enum RARITY {COMMON, UNCOMMON, RARE, MYTHICAL}

var TEXT_COLOR = {
	"points_gain": "#00ff00",
	"points_loss": "#ff0000",
	"money": "#ffff00",
	"rarity0": "#ffffff",
	"rarity1": "#7777ff",
	"rarity2": "#f0a020",
	"rarity3": "#a020f0",
}

var RARITY_STRING = {
	RARITY.COMMON: "[color={0}]Common[/color]".format([TEXT_COLOR.rarity0]),
	RARITY.UNCOMMON: "[color={0}]Uncommon[/color]".format([TEXT_COLOR.rarity1]),
	RARITY.RARE: "[color={0}]Rare[/color]".format([TEXT_COLOR.rarity2]),
	RARITY.MYTHICAL: "[color={0}]Mythical[/color]".format([TEXT_COLOR.rarity3]),
}

const ANIMAL_RARITY_COSTS = {
	RARITY.COMMON: 2,
	RARITY.UNCOMMON: 3,
	RARITY.RARE: 5,
	RARITY.MYTHICAL: 8,
}

var TERRAIN = {
	TERRAIN_TYPE.GRASS: {
		name = "[color=lawngreen]Grassland[/color]",
		name_raw = "Grassland",
		animals = [],
		sprite_half = preload("res://Sprites/tile_grass.png"),
		sprite_full = preload("res://Sprites/tile_grass_full.png"),
		animal_token_y = 0.25,
	},
	TERRAIN_TYPE.WATER: {
		name = "[color=aqua]Ocean[/color]",
		name_raw = "Ocean",
		animals = [],
		sprite_half = preload("res://Sprites/tile_water.png"),
		sprite_full = preload("res://Sprites/tile_water_full.png"),
		animal_token_y = 0.2,
	},
	TERRAIN_TYPE.FOREST1: {
		name = "[color=forestgreen]Boreal Forest[/color]",
		name_raw = "Boreal Forest",
		animals = [],
		sprite_half = preload("res://Sprites/tile_forest1.png"),
		sprite_full = preload("res://Sprites/tile_forest1_full.png"),
		animal_token_y = 0.34,
	},
	TERRAIN_TYPE.JUNGLE: {
		name = "[color=lime]Jungle[/color]",
		name_raw = "Jungle",
		animals = [],
		sprite_half = preload("res://Sprites/tile_jungle.png"),
		sprite_full = preload("res://Sprites/tile_jungle_full.png"),
		animal_token_y = 0.5,
	},
	TERRAIN_TYPE.DESERT: {
		name = "[color=sandybrown]Desert[/color]",
		name_raw = "Desert",
		animals = [],
		sprite_half = preload("res://Sprites/tile_desert.png"),
		sprite_full = preload("res://Sprites/tile_desert_full.png"),
		animal_token_y = 0.25,
	},
	SPECIAL_TERRAIN_TYPE.VOLCANO: {
		name = "[color=red]Volcano[/color]",
		name_raw = "Volcano",
		animal_token_y = 0.6
	},
	SPECIAL_TERRAIN_TYPE.ROCK: {
		name = "[color=gray]Rock[/color]",
		name_raw = "Rock",
		sprite_full = preload("res://Sprites/tile_rock_full.png"),
		animal_token_y = 0.25
	},
}

var ANIMAL_CATEGORY = {
	ANIMAL_TYPE.BIRD: {
		name = "Bird",
		name_plural = "Birds",
		animals = [],
		text_color = "#0098ff",
		#string = "" ## BBCode string is added in _init()
	},
	ANIMAL_TYPE.HERBIVORE: {
		name = "Herbivore",
		name_plural = "Herbivores",
		animals = [],
		text_color = "#00ff00",
	},
	ANIMAL_TYPE.PREDATOR: {
		name = "Predator",
		name_plural = "Predators",
		animals = [],
		text_color = "#ff0000",
	},
	ANIMAL_TYPE.REPTILE: {
		name = "Reptile",
		name_plural = "Reptiles",
		animals = [],
		text_color = "#008060",
	},
	ANIMAL_TYPE.RODENT: {
		name = "Rodent",
		name_plural = "Rodents",
		animals = [],
		text_color = "#f07720",
	}
}

var BOSS = {
	Volcano = {
		sprite = preload("res://Sprites/boss_volcano.png"),
		description = format_string("Shuffles a temporary <terrain={0}> tile into your deck"
				.format([SPECIAL_TERRAIN_TYPE.ROCK])
				+ " whenever you place a tile next to the Volcano"),
	}
}

func _init():
	var dirname = "res://Scripts/Animals"
	var animal_files = list_files_in_folder(dirname)
	for fname in animal_files:
		if fname.ends_with(".gd") or fname.ends_with(".gdc"):
			var animal = load(dirname.path_join(fname)).new()
			if animal.exclude == false:
				ANIMAL.append(animal)
				print("Loading animal: ", animal.name)
	
	for animal in ANIMAL:
		for habitat in animal.habitats:
			TERRAIN[habitat].animals.append(animal)
		for category in animal.categories:
			ANIMAL_CATEGORY[category].animals.append(animal)
	
	for key in ANIMAL_CATEGORY:
		var categ = ANIMAL_CATEGORY[key]
		categ.string = "[color={0}]{1}[/color]".format([categ.text_color, categ.name])

func get_animal(name_: String) -> Animal:
	for animal in ANIMAL:
		if animal.name == name_:
			return animal.get_script().new()
	return null

func format_string(string: String) -> String:
	var split = split_string(string)
	var results = []
	for part in split:
		
		var regex = RegEx.create_from_string("<points=(.*)>")
		var search = regex.search(part)
		if search:
			var string_ = search.get_string(1)
			# Make sure it's a number
			if str(int(string_)) == string_:
				var color = (TEXT_COLOR.points_gain if int(string_) >= 0
						else TEXT_COLOR.points_loss)
				var string2 = "[b][color={0}]".format([color])
				if int(string_) > 0:
					string2 += "+"
				var noun = "point" if abs(int(string_)) == 1 else "points"
				results.append(string2 + string_ + "[/color][/b] " + noun)
				continue
		
		regex = RegEx.create_from_string("<money=(.*)>")
		search = regex.search(part)
		if search:
			var string_ = search.get_string(1)
			var string2 = "[b][color={0}]".format([TEXT_COLOR.money])
			if int(string_) > 0:
				string2 += "+"
			results.append(string2 + "$" + string_ + "[/color][/b]")
			continue
		
		regex = RegEx.create_from_string("<animal_category=(.*)>")
		search = regex.search(part)
		if search:
			var string_ = search.get_string(1)
			# Make sure animal category is valid
			var integer = int(string_)
			if str(integer) == string_ and integer > -1 and integer < ANIMAL_TYPE.values().size():
				var color = ANIMAL_CATEGORY[integer].text_color
				var animal = ANIMAL_CATEGORY[integer].name
				results.append("[color={0}]{1}[/color] ".format([color, animal]))
				continue
		
		regex = RegEx.create_from_string("<terrain=(.*)>")
		search = regex.search(part)
		if search:
			var string_ = search.get_string(1)
			var integer = int(string_)
			if integer in TERRAIN:
				results.append(TERRAIN[integer].name)
				continue
		
		regex = RegEx.create_from_string("<rarity=(.*)>")
		search = regex.search(part)
		if search:
			var string_ = search.get_string(1)
			var integer = int(string_)
			if integer in RARITY_STRING:
				results.append(RARITY_STRING[integer])
				continue
		
		results.append(part)
		
	return " ".join(results)

func split_string(string: String) -> Array[String]:
	var regex = RegEx.new()
	regex.compile("\\S+") # Negated whitespace character class.
	var lines = string.split("\n")
	var results: Array[String] = []
	for line in lines:
		for result in regex.search_all(line):
			results.push_back(result.get_string())
		results.push_back("\n")
	# Trim line break from end
	results.pop_back()
	return results

func list_files_in_folder(folder_path: String) -> Array:
	var files := []
	
	var dir_access := DirAccess.open(folder_path)
	
	if dir_access:
		# Start iterating through directory contents
		dir_access.list_dir_begin()
		var file_name = dir_access.get_next()
		
		while file_name != "":
			# Ignore "." and ".." which are current and parent directory
			if file_name != "." and file_name != "..":
				# Check if the current item is a file
				if not dir_access.current_is_dir():
					files.append(file_name)
			file_name = dir_access.get_next()
		
		dir_access.list_dir_end()
	else:
		print("Failed to open folder: ", folder_path)
	
	return files
