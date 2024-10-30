extends VBoxContainer

var item : ClickableControl
var cost : int

@onready var button := $Button

func set_item(node: ClickableControl, cost_: int) -> void:
	set_empty(false)
	if item:
		item.queue_free()
	item = node
	node.selectable = false
	add_child(node)
	move_child(node, 0)
	cost = cost_
	button.set_text("$" + str(cost_))

func set_can_afford(money: int) -> void:
	if money >= cost:
		button.modulate = Color.WHITE
	else:
		button.modulate = Color.RED

func set_empty(empty: bool = true) -> void:
	button.visible = !empty
