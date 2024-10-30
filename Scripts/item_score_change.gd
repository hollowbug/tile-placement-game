extends ScoreChange
class_name ItemScoreChange

var item : Item

func _init(item_: Item, inc: int = 0, dec: int = 0) -> void:
	item = item_
	increase = inc
	decrease = dec
