class_name Tile
extends GridObject

signal tile_hovered(tile: Tile)
signal tile_unhovered(tile: Tile)
signal tile_clicked(tile: Tile, mouse_button: int)

@export var tile_data: TileResource:
	set(value):
		tile_data = value
		if is_inside_tree():
			_apply_tile_settings()

#Functionality
var gameplay_state: G.GameplayState = G.GameplayState.EMPTY
var tile_state: G.TileState = G.TileState.NORMAL
#Sizes
var tile_size: Vector3 = Vector3(1.0, 0.2, 1.0)
var hitbox_size: Vector3
var hitbox_y_offset: float
#Positive Interractions
var lift_height: float = 0.3
var lift_speed: float = 0.15
#Negative Interractions
var shake_intensity: float = 0.1

var original_mesh_position: Vector3
var lifted_mesh_position: Vector3
var is_hovered: bool = false
var current_tween: Tween

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var area: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D


func _ready() -> void:
	original_mesh_position = mesh_instance.position
	lifted_mesh_position = original_mesh_position + Vector3(0, lift_height, 0)
	
	hitbox_size = Vector3(tile_size.x, tile_size.y, tile_size.z)
	hitbox_y_offset = lift_height
	
	if tile_data:
		_apply_tile_settings()
	if mesh_instance:
		var random_rotation = randi() % 4 * 90
		mesh_instance.rotation_degrees.y = random_rotation
		#mesh_instance.rotation.y = randf() * TAU  # TAU = 2*PI
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)

func _apply_tile_settings() -> void:
	if !tile_data:
		return
	if mesh_instance:
		mesh_instance.mesh.size = tile_size
		
		if tile_data.material && !tile_data.ignore_albedo:
			var new_material = tile_data.material.duplicate()
			new_material.albedo_color = tile_data.albedo_color
			mesh_instance.material_override = new_material
		elif tile_data.material:
			mesh_instance.material_override = tile_data.material
	if collision_shape:
		collision_shape.shape.size = hitbox_size
		collision_shape.position.y += hitbox_y_offset

func _process(delta):
		pass

#region Interractions
func _on_mouse_entered() -> void:
	tile_hovered.emit(self)
	on_mouse_entered()

func _on_mouse_exited() -> void:
	tile_unhovered.emit(self)
	on_mouse_exited()

func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		tile_clicked.emit(self, event.button_index)
		on_click(event)
		
func on_mouse_entered() -> void:
	is_hovered = true
	var tween = create_tween()
	tween.tween_property(mesh_instance, "position", lifted_mesh_position, lift_speed).set_trans(Tween.TRANS_QUAD)

func on_mouse_exited() -> void:
	is_hovered = false
	var tween = create_tween()
	tween.tween_property(mesh_instance, "position", original_mesh_position, lift_speed).set_trans(Tween.TRANS_QUAD)

func on_click(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if gameplay_state == G.GameplayState.EMPTY:
			match tile_state:
				G.TileState.NORMAL:
					_tile_action_normal()
				G.TileState.CHALKED:
					_tile_action_chalked()
				G.TileState.ENDGAME:
					_tile_action_blocked()
				G.TileState.DEAD:
					pass
				_:
					pass
		elif gameplay_state == G.GameplayState.OCCUPIED:
			_tile_action_blocked()
#endregion
#region Interaction processing
func _tile_action_normal():
	#tile to dead state
	queue_free()
	pass

func _tile_action_chalked():
	#clear chalk
	pass

func _tile_action_blocked():
	#shaking
	pass
#endregion
