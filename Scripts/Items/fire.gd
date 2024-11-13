extends ItemData

func _init(id_: int):
	super(id_)
	exclude = false
	instant = true
	name = "Fire"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/fire.png")

func get_description() -> String:
	return "Remove a tile from your deck"
