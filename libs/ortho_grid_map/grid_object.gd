extends Node3D
class_name GridObject

signal mouse_entered
signal mouse_exited
signal clicked(event: InputEventMouseButton)

## Position in staggered isometric grid
var cell_position: Vector2i:
	get: return _cell_position
## Position in true isometric grid
var cell_true_position: Vector2i:
	get: return _cell_true_position
## World position (XZ plane)
var world_position: Vector2:
	get: return _world_position
## Grid map reference
var grid_map: OrthoGridMap

var _cell_position: Vector2i
var _cell_true_position: Vector2i
var _world_position: Vector2

var _area: Area3D
var _collision_shape: CollisionShape3D

func _ready() -> void:
	grid_map = get_parent() as OrthoGridMap
	if not grid_map:
		push_error("GridObject must be a child of OrthoGridMap")
	_setup_area()

func _setup_area() -> void:
	_area = Area3D.new()
	_collision_shape = CollisionShape3D.new()
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(grid_map.cell_size.x, 0.1, grid_map.cell_size.y)
	_collision_shape.shape = box_shape
	
	_area.add_child(_collision_shape)
	add_child(_area)
	
	_area.mouse_entered.connect(_on_area_mouse_entered)
	_area.mouse_exited.connect(_on_area_mouse_exited)
	_area.input_event.connect(_on_area_input_event)

func _on_area_mouse_entered() -> void:
	mouse_entered.emit()
	on_mouse_entered()

func _on_area_mouse_exited() -> void:
	mouse_exited.emit()
	on_mouse_exited()

func _on_area_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked.emit(event)
		on_click(event)
		
func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass

func on_click(event: InputEventMouseButton) -> void:
	pass
