@icon("res://libs/ortho_grid_map/grid_obj.svg")
class_name GridObject
extends Node3D

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

func _ready() -> void:
	grid_map = get_parent() as OrthoGridMap
	if not grid_map:
		push_error("GridObject must be a child of OrthoGridMap")
