extends Control

@onready var _parent := get_parent()
#@onready var position3D := Vector3.ZERO

var camera: Camera3D

func _process(_delta) -> void:
	if not camera:
		camera = get_viewport().get_camera_3d()
	position = camera.unproject_position(_parent.global_position)# + position3D)
