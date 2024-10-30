extends DirectionalLight3D

@export var start_at_random_rotation := true
@export_range(0, 1) var rotation_speed := 0.01

func _ready():
	if start_at_random_rotation:
		rotate_y(randf() * TAU)

func _process(delta):
	rotate_y(delta * rotation_speed)
