extends Resource
class_name ItemScoreChange

var item : Item
var score_change : int
var money_change : int

func _init(item_: Item, score_change_: int, money_change_: int = 0) -> void:
	item = item_
	score_change = score_change_
	money_change = money_change_
