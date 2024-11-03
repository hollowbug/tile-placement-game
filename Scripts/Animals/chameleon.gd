extends Animal

func _init():
	exclude = false
	name = "Chameleon"
	name_plural = "Chameleons"
	sprite = preload("res://Sprites/chameleon.png")
	categories = [Globals.ANIMAL_TYPE.REPTILE, Globals.ANIMAL_TYPE.BIRD,
			Globals.ANIMAL_TYPE.HERBIVORE, Globals.ANIMAL_TYPE.PREDATOR, Globals.ANIMAL_TYPE.RODENT]
	habitats = [Globals.TERRAIN_TYPE.JUNGLE]
	rarity = Globals.RARITY.MYTHICAL
	description = "Counts as any animal"
