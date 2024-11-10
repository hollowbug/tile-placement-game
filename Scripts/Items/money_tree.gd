extends ItemData

func _init(id_: int):
	super(id_)
	exclude = false
	name = "Money Tree"
	rarity = Globals.RARITY.COMMON
	sprite = preload("res://Sprites/Items/money_tree.png")

func get_description() -> String:
	return Globals.format_string("<money=3> when entering the shop")

func on_shop_entered(item, changes) -> void:
	changes.add_item(ItemScoreChange.new(item, 0, 3))
