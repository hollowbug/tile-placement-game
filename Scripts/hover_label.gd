extends Label

var FONT := get_theme_default_font()

@onready var panel = $Description

@export_multiline var description : String

func _ready():
	if description:
		set_description(description)
		
#func _process(_delta):
#func _input(event):
	#if event is InputEventKey and event.keycode == KEY_ENTER:
		#panel.size = Vector2()

func set_description(description_: String) -> void:
	#print("Font: ", FONT)
	var label = $Description/HBoxContainer/Label
	label.set_text(description_)
	panel.size = Vector2()
	#var size_ = FONT.get_string_size(description_, HORIZONTAL_ALIGNMENT_LEFT, -1,
			#label.get_theme_font_size("font_size"))
	#print("Font size: ", label.get_theme_font_size("font_size"))
	#print("Size: ", size_)
	#if size_.x < 600:
		#panel.custom_minimum_size = Vector2(size_.x + 32, 0)
	#else:
		#panel.custom_minimum_size = Vector2(632, 0)

func _on_mouse_entered():
	panel.visible = true
	#panel.global_position = get_global_mouse_position()

func _on_mouse_exited():
	panel.visible = false
