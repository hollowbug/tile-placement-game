extends Resource
class_name ItemScoreChange

var item : Item
var score_change : int

func _init(item_: Item, score_change_: int) -> void:
	item = item_
	score_change = score_change_
