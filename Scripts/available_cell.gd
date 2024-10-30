extends Tile

@onready var collider = get_node("StaticBody3D/CollisionPolygon3D")

func _ready():
	scale = Vector3(0.98, 1, 0.98)

func _on_static_body_3d_mouse_entered():
	mouse_entered.emit(self)

func _on_static_body_3d_mouse_exited():
	mouse_exited.emit(self)

func _on_static_body_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	input_event.emit(self, event)

func enable_colliders(enabled: bool = true) -> void:
	collider.disabled = !enabled
