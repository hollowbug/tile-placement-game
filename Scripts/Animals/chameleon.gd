extends Animal

func _init():
	exclude = false
	name = "Chameleon"
	name_plural = "Chameleons"
	sprite = preload("res://Sprites/chameleon.png")
	categories = [Globals.ANIMAL_TYPE.REPTILE]
	habitats = [Globals.TERRAIN_TYPE.JUNGLE]
	rarity = Globals.RARITY.MYTHICAL
