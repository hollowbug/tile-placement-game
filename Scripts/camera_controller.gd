extends Node3D

signal object_clicked(object : Node3D)
signal right_click

#####################
# EXPORT PARAMS
#####################
# movement params
@export_range(0,1000) var movement_speed: float = 15
@export_range(0,1000) var camera_bounds_margin: int = 100
# rotation params
@export_range(0,90) var min_elevation_angle: int = 10
@export_range(0,90) var max_elevation_angle: int = 90
@export_range(0,1000, 0.1) var rotation_speed: float = 5
# zoom
@export_range(0,1000) var min_zoom: int = 5
@export_range(0,1000) var max_zoom: int = 20
@export_range(0,1000, 0.1) var zoom_speed: float = 50
@export_range(0,1000, 0.1) var zoom_speed_damp: float = 0.5
#edge
@export_range(0,1000) var edge_margin: float = 50
@export_range(0,10, 0.5) var edge_speed: float = 3
#pan
@export_range(0,10, 0.01) var pan_speed: float = 2
# clicks
@export_range(10, 1000) var click_time_limit: int = 500
@export_range(0, 100) var click_distance_limit: int = 10
# flags
@export var allow_rotation: bool = true
@export var inverted_y: bool = false
@export var zoom_to_cursor: bool = true
@export var allow_pan: bool = true

#####################
# PARAMS
#####################
# movement
var _last_mouse_position = Vector2()
var _is_rotating = false
@onready var Elevation: Node3D = $Elevation
# zoom
var _zoom_direction = 0
@onready var Camera: Camera3D = $Elevation/Camera3D
const GROUND_PLANE = Plane(Vector3.UP, 0)
const RAY_LENGTH = 1000
# pan
var _is_panning = false
var _last_drag_point = Vector3()
var _pan_constraints = Rect2(0.0, 0.0, 0.0, 0.0)
# clicking
var _click_time : int
var _click_position : Vector2

###
# PUBLIC FUNCTIONS
###

func expand_pannable_area(point: Vector3) -> void:
	_pan_constraints = _pan_constraints.expand(Vector2(point.x, point.z))

#####################
# OVERRIDE FUNCTIONS
#####################

#func _ready() -> void:
	# point camera at the controller so that it orbits around the controller
	#Camera.look_at(-Camera.position, Vector3.UP)

func _process(delta) -> void:
	#_edge_move(delta)
	#_move(delta)
	_rotate(delta)
	_zoom(delta)
	#_pan(delta)
	#_constrain_view()
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	# test if we are rotating
	if event.is_action_pressed("camera_rotate"):
		_is_rotating = true
		_last_mouse_position = get_viewport().get_mouse_position()
	if event.is_action_released("camera_rotate"): 
		_is_rotating = false
	
	# test if we are zooming
	if event.is_action_pressed("camera_zoom_in"):
		_zoom_direction = -1
	if event.is_action_pressed("camera_zoom_out"):
		_zoom_direction = 1
		
	# test if we are rotating
	if event.is_action_pressed("camera_pan"):
		_is_panning = true
		_last_mouse_position = get_viewport().get_mouse_position()
		_last_drag_point = _get_ground_click_location()
	if event.is_action_released("camera_pan"): 
		_is_panning = false
		_last_drag_point = position
		
	# handle clicks
	if event is InputEventMouseButton and event.pressed:
		_click_time = Time.get_ticks_msec()
		_click_position = get_viewport().get_mouse_position()
	
	if event is InputEventMouseButton and !event.pressed:
		var click_time = Time.get_ticks_msec() - _click_time
		var click_distance = _click_position.distance_to(get_viewport().get_mouse_position())
		if click_time < click_time_limit and click_distance <= click_distance_limit:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_on_left_click()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				right_click.emit()

#####################
# MOVEMENT FUNCTIONS
#####################
func _move(delta: float) -> void:
	# initialize a velocity vector
	var velocity = Vector3()

	# populate it
	if Input.is_action_pressed("camera_forward"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("camera_backward"):
		velocity += transform.basis.z
	if Input.is_action_pressed("camera_left"):
		velocity -= transform.basis.x
	if Input.is_action_pressed("camera_right"):
		velocity += transform.basis.x
	# normalize and clamp speed
	velocity = velocity.normalized()
	# translate
	global_translate(velocity * delta * movement_speed)
	
	position = position.clamp(
		Vector3(float(camera_bounds_margin),float(max_zoom),float(camera_bounds_margin)) * -1, 
		Vector3(float(camera_bounds_margin),float(max_zoom),float(camera_bounds_margin))
		)

func _rotate(delta: float) -> void:
	if !_is_rotating || !allow_rotation:
		return 
	# calculate mouse movement
	var displacement = _get_mouse_displacement()
	# use horizontal displacement to rotate
	_rotate_left_right(delta, displacement.x)
	# use the vertical displacement to elevate
	_elevate(delta, displacement.y)
	
func _edge_move(delta: float) -> void:
	var viewport = get_viewport()
	if not viewport.get_window().has_focus():
		return
	# initialize a velocity vector
	var velocity = Vector3()
	var visible_rect = viewport.get_visible_rect()
	# get mouse position
	var m_pos = viewport.get_mouse_position()
	# populate it
	if m_pos.x < edge_margin:
		velocity.x = lerp(
			velocity.x,
			velocity.x - abs(m_pos.x - edge_margin)/edge_margin * edge_speed, 
			edge_speed * delta 
		)
	elif m_pos.x > visible_rect.size.x - edge_margin:
		velocity.x = lerp(
			velocity.x,
			velocity.x + abs(m_pos.x - visible_rect.size.x + edge_margin)/edge_margin * edge_speed, 
			edge_speed * delta 
		)
	if m_pos.y < edge_margin:
		velocity.z = lerp(
			velocity.z,
			velocity.z - abs(m_pos.y - edge_margin)/edge_margin * edge_speed, 
			edge_speed * delta 
		)
	elif m_pos.y > visible_rect.size.y - edge_margin:
		velocity.z = lerp(
			velocity.z,
			velocity.z + abs(m_pos.y - visible_rect.size.y + edge_margin)/edge_margin * edge_speed, 
			edge_speed * delta 
		)
	global_translate(velocity.rotated(Vector3(0,1,0), rotation.y))


func _pan(_delta: float) -> void:
	if !_is_panning || !allow_pan:
		return
	# get the mouse displacement
	var new_position = position + _last_drag_point - _get_ground_click_location()
	# transform the displacement into velocity
	position = position.lerp(new_position,0.5)

func _constrain_view() -> void:
	position.x = clamp(position.x, _pan_constraints.position.x, _pan_constraints.end.x)
	position.z = clamp(position.z, _pan_constraints.position.y, _pan_constraints.end.y)

#####################
# ZOOM FUNCTIONS
#####################
func _zoom(delta: float) -> void:
	# calculate the new zoom and clamp zoom between min and max
	var new_zoom = clamp(
		Camera.position.z + zoom_speed * delta * _zoom_direction * sqrt(Camera.position.z),
		min_zoom,
		max_zoom
		)
	# save 3d position
	var pointing_at = _get_ground_click_location()
	# zoom
	Camera.position.z = new_zoom
	# move the camera such that we are pointing at the same location
	if zoom_to_cursor && pointing_at != null:
		_realign_camera(pointing_at)
	# stop scrolling
	_zoom_direction *= zoom_speed_damp
	if abs(_zoom_direction) <= 0.0001:
		_zoom_direction = 0;

#####################
# HELPER FUNCTIONS
#####################
func _get_mouse_displacement() -> Vector2:
	var current_mouse_position = get_viewport().get_mouse_position()
	var displacement = current_mouse_position - _last_mouse_position
	_last_mouse_position = current_mouse_position
	return displacement

func _rotate_left_right(delta: float, val: float) -> void:
	rotation.y += deg_to_rad(val * delta * rotation_speed) * -1

func _elevate(delta: float, val: float) -> void:
	# calculate new elevation
	var new_elevation = rad_to_deg(Elevation.rotation.x)
	if inverted_y:
		new_elevation += val * delta * rotation_speed
	else:
		new_elevation -= val * delta * rotation_speed
	# clamp the new elevation
	new_elevation = clamp(
		new_elevation, 
		-max_elevation_angle, 
		-min_elevation_angle
		)
	Elevation.rotation.x = deg_to_rad(new_elevation)
	# set the new elevation based on the clamped value
	
func _get_ground_click_location():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = Camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + Camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	return GROUND_PLANE.intersects_ray(ray_from, ray_to)

func _realign_camera(location: Vector3) -> void:
	# calculate where we need to move
	var new_location = _get_ground_click_location()
	var displacement = location - new_location
	# move the camera based on that calculation
	position += displacement

func _on_left_click():
	var from = Camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + Camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		object_clicked.emit(result.collider)
