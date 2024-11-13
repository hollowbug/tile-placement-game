extends Tile
class_name HabitatTile

#signal mouse_entered_half1(tile: HabitatTile)
#signal mouse_entered_half2(tile: HabitatTile)
#var material = preload("res://new_standard_material_3d.tres")
var data : TileData_
var is_split : bool
var edges : Array
var animal_score := [0, 0]
var habitats : Dictionary = {}
var preview_habitats : Dictionary = {}
var preview_animals : Array[Animal]
var ignore_hover = false
var rotations := 0

var _hovered := false
var _hover_timer := 0.0
var _score_tween : Array[Tween] = [null, null]
var _raise_tween : Array[Tween] = [null, null]
var _HIGHLIGHTS : Array[Node]
var _pieces : Array[Node] = []
static var _PIECE_SCENES = {
	Globals.TERRAIN_TYPE.GRASS: {
		full = preload("res://3D/grass_full.glb"),
		half = preload("res://3D/grass_half.glb"),
	},
	Globals.TERRAIN_TYPE.FOREST1: {
		full = preload("res://3D/boreal_full.glb"),
		half = preload("res://3D/boreal_half.glb"),
	},
	Globals.TERRAIN_TYPE.WATER: {
		full = preload("res://3D/water_full.glb"),
		half = preload("res://3D/water_half.glb"),
	},
	Globals.TERRAIN_TYPE.JUNGLE: {
		full = preload("res://3D/jungle_full.glb"),
		half = preload("res://3D/jungle_half.glb"),
	},
	Globals.TERRAIN_TYPE.DESERT: {
		full = preload("res://3D/desert_full.glb"),
		half = preload("res://3D/desert_half.glb"),
	},
	Globals.SPECIAL_TERRAIN_TYPE.VOLCANO: {
		full = preload("res://3D/Hex Tiles/volcano.obj")
	},
	Globals.SPECIAL_TERRAIN_TYPE.ROCK: {
		full = preload("res://3D/rock_full.glb")
	},
}

@onready var COLLIDER_FULL = $Area3D
#@onready var COLLIDER_FULL = $ColliderFull
#@onready var COLLIDER1 = $Collider1
#@onready var COLLIDER2 = $Collider2
@onready var _TILE_INFO = $Control/TileInfo
@onready var ANIMAL_TOKEN = [$AnimalToken0, $AnimalToken1]
@onready var ANIMAL_ADDED = [$AnimalToken0/AddAnimal, $AnimalToken1/AddAnimal]
@onready var ANIMAL_REMOVED = [$AnimalToken0/RemoveAnimal, $AnimalToken1/RemoveAnimal]
@onready var ANIMAL_UI = [$AnimalToken0/AnimalUI, $AnimalToken1/AnimalUI]
@onready var ANIMAL_SCORE_RECT = [ANIMAL_UI[0].get_node("ScoreRect"), ANIMAL_UI[1].get_node("ScoreRect")]
@onready var DEBUG_LABEL = $DebugUI/Label

func _ready() -> void:
	scale = Vector3(0.98, 1, 0.98)
	is_empty_slot = false
	_HIGHLIGHTS = [
		$Highlight0,
		$Highlight1,
		$Highlight2,
		$Highlight3,
		$Highlight4,
		$Highlight5,
		$Highlight6,
	]

func _process(delta):
	#DEBUG_LABEL.visible = visible
	#DEBUG_LABEL.set_text(str(coordinates))
	if _hovered:
		_TILE_INFO.modulate.a = min(1.0, _hover_timer / 0.2)
		_hover_timer += delta
		#if _hover_timer > 0.2:

func set_data(data_: TileData_) -> HabitatTile:
	data = data_
	update_description()
	edges = [data.terrain[0], data.terrain[0], data.terrain[0], data.terrain[1], data.terrain[1], data.terrain[1]]
	is_split = data.terrain[0] != data.terrain[1]
	
	for piece in _pieces:
		piece.queue_free()
	
	if is_split:
		var piece0 = _PIECE_SCENES[data.terrain[0]].half.instantiate()
		add_child(piece0)
		_pieces.append(piece0)
		var piece1 = _PIECE_SCENES[data.terrain[1]].half.instantiate()
		piece1.rotate_y(PI)
		add_child(piece1)
		_pieces.append(piece1)
	else:
		var piece = _PIECE_SCENES[data.terrain[0]].full.instantiate()
		add_child(piece)
		_pieces.append(piece)

	preview_animals = data.animal.duplicate()
	update_animal(0)
	update_animal(1)
	_position_animal_ui()
	return self

#func autotile(neighbors: Array) -> void:
	#for tile in edge_nodes:
		#tile.queue_free()
	#edge_nodes = []
	#for i in range(6):
		#if edges[i] == Globals.TERRAIN_TYPE.WATER and !neighbors[i]:
			#var node = _PIECE_SCENES[Globals.TERRAIN_TYPE.WATER].edge.instantiate()
			#node.rotate_y(i * PI / 3 - rotation.y)
			#edge_nodes.append(node)
			#add_child(node)

func update_description() -> void:
	_TILE_INFO.set_data(data)

func get_habitat(terrain: int) -> Array[HabitatTile]:
	if terrain in preview_habitats:
		return preview_habitats[terrain]
	elif terrain in habitats:
		return habitats[terrain]
	else:
		print("===========\nHabitatTile.get_habitat() Error")
		print("Terrain: ", terrain)
		print("Habitats: ", habitats)
		print("Habitats Preview: ", preview_habitats, "\n===========")
		return []
	
func rotate_tile(steps_cw: int) -> void:
	rotations -= steps_cw
	rotate_y(-steps_cw * PI / 3)
	for i in range(2):
		ANIMAL_TOKEN[i].rotate_object_local(Vector3.UP, steps_cw * PI / 3)
	for i in range(steps_cw):
		edges.append(edges.pop_front())

func preview_placement(neighbors: Array[Tile]) -> void:
	preview_habitats[data.terrain[0]] = [self] as Array[HabitatTile]
	raise_habitat(data.terrain[0])
	if is_split:
		preview_habitats[data.terrain[1]] = [self] as Array[HabitatTile]
		raise_habitat(data.terrain[1])
	for i in range(6):
		if neighbors[i] and edges[i] == neighbors[i].edges[(i+3)%6]:
			var neighbor_habitat = neighbors[i].get_habitat(edges[i])
			if neighbor_habitat != preview_habitats[edges[i]]:
				for tile in neighbor_habitat:
					tile.raise_habitat(edges[i])
					if preview_habitats[edges[i]].find(tile) == -1:
						tile.preview_habitats[edges[i]] = preview_habitats[edges[i]]
						preview_habitats[edges[i]].append(tile)
	#print("\nHabitats preview:")
	#for key in preview_habitats:
		#print(Globals.TERRAIN[key].name, ": ", preview_habitats[key].size())

func commit_placement() -> void:
	for key in preview_habitats:
		for tile in preview_habitats[key]:
			if tile == self:
				continue
			tile.habitats[key] = preview_habitats[key]
	habitats = preview_habitats

func raise_habitat(terrain: int) -> void:
	for i in range(2):
		if _pieces.size() > i and data.terrain[i] == terrain:
			if _raise_tween[i]:
				_raise_tween[i].kill()
			_pieces[i].position.y = 0
			_raise_tween[i] = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel()
			_raise_tween[i].tween_property(_pieces[i], "position:y", 0.2, 0.2).set_ease(Tween.EASE_OUT)
			var y = Globals.TERRAIN[data.terrain[i]].animal_token_y
			_raise_tween[i].tween_property(ANIMAL_TOKEN[i], "position:y", y + 0.2, 0.2).set_ease(Tween.EASE_OUT)

func clear_preview() -> void:
	preview_habitats = {}
	_hide_animal_preview()
	for i in range(2):
		if _raise_tween[i]:
			_raise_tween[i].kill()
		if _pieces.size() > i:
			_raise_tween[i] = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel()
			_raise_tween[i].tween_property(_pieces[i], "position:y", 0, 0.2).set_ease(Tween.EASE_OUT)
			var y = Globals.TERRAIN[data.terrain[i]].animal_token_y
			_raise_tween[i].tween_property(ANIMAL_TOKEN[i], "position:y", y, 0.2).set_ease(Tween.EASE_OUT)

func enable_colliders(enabled: bool = true) -> void:
	COLLIDER_FULL.get_node("CollisionPolygon3D").disabled = !enabled
	ignore_hover = true
	#COLLIDER1.get_node("CollisionPolygon3D").disabled = !enabled
	#COLLIDER2.get_node("CollisionPolygon3D").disabled = !enabled

func show_() -> void:
	visible = true
	ANIMAL_UI[0].visible = true
	ANIMAL_UI[1].visible = true

func hide_() -> void:
	visible = false
	ANIMAL_UI[0].visible = false
	ANIMAL_UI[1].visible = false

func show_animal_preview(preview: TileChange) -> void:
	if preview.score_change != 0 or preview.money_change != 0:
		ANIMAL_SCORE_RECT[preview.animal_idx].show_score(preview.score_change, true, preview.money_change)
	if data.animal[preview.animal_idx] and !preview_animals[preview.animal_idx]:
		ANIMAL_REMOVED[preview.animal_idx].visible = true
		update_animal(preview.animal_idx)
	if !data.animal[preview.animal_idx] and preview_animals[preview.animal_idx]:
		ANIMAL_ADDED[preview.animal_idx].visible = true
		update_animal(preview.animal_idx)

func commit_animal_preview() -> void:
	data.animal = preview_animals
	_TILE_INFO.set_data(data)
	for i in range(2):
		ANIMAL_SCORE_RECT[i].hide_score()
		ANIMAL_TOKEN[i].visible = data.animal[i] != null

func update_animal(animal_idx: int) -> void:
	if preview_animals[animal_idx]:
		ANIMAL_TOKEN[animal_idx].visible = true
		var animal_mesh = ANIMAL_TOKEN[animal_idx].get_node("Animal")
		var material: StandardMaterial3D = animal_mesh.get_active_material(0)
		var new = material.duplicate(true)
		new.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, preview_animals[animal_idx].sprite)
		animal_mesh.set_surface_override_material(0, new)

func _hide_animal_preview() -> void:
	preview_animals = data.animal.duplicate()
	for i in range(2):
		ANIMAL_TOKEN[i].visible = true if preview_animals[i] else false
		ANIMAL_SCORE_RECT[i].hide_score()
		ANIMAL_REMOVED[i].visible = false
		ANIMAL_ADDED[i].visible = false

func _position_animal_ui() -> void:
	var y = Globals.TERRAIN[data.terrain[0]].animal_token_y
	if is_split:
		ANIMAL_TOKEN[0].position = Vector3(0.25, y, 0).rotated(Vector3.UP, PI / 3 * 0.5)
		y = Globals.TERRAIN[data.terrain[1]].animal_token_y
		ANIMAL_TOKEN[1].position = Vector3(0.25, y, 0).rotated(Vector3.UP, PI / 3 * 3.5)
	else:
		ANIMAL_TOKEN[0].position = Vector3(0, y, 0)


func _on_collider_full_mouse_entered() -> void:
	if ignore_hover:
		ignore_hover = false
	else:
		_hovered = true

func _on_collider_full_mouse_exited() -> void:
	_hovered = false
	_hover_timer = 0
	_TILE_INFO.modulate.a = 0
		
##############
# OLD CODE
##############

#func set_material(material) -> void:
	#for mesh in meshes:
		#mesh.set_surface_override_material(0, material)

#func _load_pieces() -> void:
	#for i in range(6):
		#if edges[i] == Globals.TERRAIN_TYPE.GRASS:
			#var piece = _EDGE_SCENES.grass.instantiate()
			#piece.rotate_y((i - 0.5) * PI / 3)
			#add_child(piece)
			#_pieces.append(piece)
	#meshes = find_children("", "MeshInstance3D", true, false)

#func autotile(neighbors: Array[Tile]) -> void:
	#for piece in _pieces:
		#piece.queue_free()
	#_pieces = []
	##print("==================")
	##print(neighbors)
	#for i in range(6):
		#var neighbor_terrain = neighbors[i].edges[(i+3)%6] if neighbors[i] else null
		#if edges[i] == Globals.TERRAIN_TYPE.WATER:
			#if neighbors[i] and neighbor_terrain == Globals.TERRAIN_TYPE.GRASS:
				#if edges[(i+5)%6] == Globals.TERRAIN_TYPE.GRASS and (
					#!neighbors[(i+5)%6] or neighbors[(i+5)%6].edges[(i+2)%6] != Globals.TERRAIN_TYPE.WATER
				#):
					#var piece = _EDGE_SCENES.water_corner.instantiate()
					#piece.translate(Vector3(Globals.CELL_SIZE, 0, 0).rotated(Vector3.UP, (i-1) * PI / 3))
					#piece.rotate_y((i + 1.5) * PI / 3)
					#add_child(piece)
					#_pieces.append(piece)
				#elif edges[(i+1)%6] == Globals.TERRAIN_TYPE.GRASS and (
					#!neighbors[(i+1)%6] or neighbors[(i+1)%6].edges[(i+4)%6] != Globals.TERRAIN_TYPE.WATER
				#):
					#var piece = _EDGE_SCENES.water_corner.instantiate()
					#piece.translate(Vector3(Globals.CELL_SIZE, 0, 0).rotated(Vector3.UP, i * PI / 3))
					#piece.rotate_y((i - 2.5) * PI / 3)
					#add_child(piece)
					#_pieces.append(piece)
			#
		#elif edges[i] == Globals.TERRAIN_TYPE.GRASS:
			#var piece = _EDGE_SCENES.grass
			#if neighbors[i] and neighbor_terrain == Globals.TERRAIN_TYPE.WATER:
				#if neighbors[(i+5)%6] and edges[(i+5)%6] == Globals.TERRAIN_TYPE.WATER:
					#if neighbors[(i+5)%6].edges[(i+1)%6] == Globals.TERRAIN_TYPE.WATER and neighbors[(i+5)%6].edges[(i+2)%6] == Globals.TERRAIN_TYPE.WATER:
						#piece = _EDGE_SCENES.grass_right
					#else:
						#piece = _EDGE_SCENES.grass_sand_right
				#elif  neighbors[(i+1)%6] and edges[(i+1)%6] == Globals.TERRAIN_TYPE.WATER:
					#if neighbors[(i+1)%6].edges[(i+5)%6] == Globals.TERRAIN_TYPE.WATER and neighbors[(i+1)%6].edges[(i+4)%6] == Globals.TERRAIN_TYPE.WATER:
						#piece = _EDGE_SCENES.grass_left
					#else:
						#piece = _EDGE_SCENES.grass_sand_left
			#piece = piece.instantiate()
			#piece.rotate_y((i - 0.5) * PI / 3)
			#add_child(piece)
			#_pieces.append(piece)
