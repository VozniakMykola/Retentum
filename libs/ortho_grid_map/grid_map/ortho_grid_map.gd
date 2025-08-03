## 3D grid designed to work with orthogonal view. Supports 2 orthogonal coordinate systems.
##
## [b]Coordinate systems:[/b][br]
## [b]1. Staggered Isometric[/b] (Default) - Cartesian grid is overlaid at a 45° angle and implemented by offsetting rows or columns to align the coordinate logic with the visual diagonal arrangement of tiles.[br]
## [img width=300]res://libs/ortho_grid_map/Staggered_ Iso.png[/img][br]
## [b]2. True Isometric[/b] - Cartesian grid aligns directly with the tile axes without any offsets, meaning the coordinates are logically and visually aligned along the grid axes.[br]
## [img width=300]res://libs/ortho_grid_map/True_ Iso.png[/img][br]
@icon("res://libs/ortho_grid_map/grid_map.svg")
class_name OrthoGridMap
extends Node3D

@export var cell_size: Vector2 = Vector2(1.0, 1.0):
	set(value):
		cell_size = value if value != Vector2.ZERO else Vector2.ONE
		_update_children()
@export var y_index: float = 0:
	set(value):
		y_index = value
		self.position.y = value

var _grid_objects: Dictionary = {}  # Stores grid objects by their positions

#not implemented
#@export var layer_index: int = 0
#enum GridAlignment { XY, XZ, YZ }
#@export var grid_alignment: GridAlignment = GridAlignment.XZ

func _ready():
	child_exiting_tree.connect(_on_child_exiting)

func _on_child_exiting(node: Node):
	if node is GridObject and not is_instance_valid(node.get_parent()):
		_grid_objects.erase(node.cell_position)

#region Transformations between coordinate systems
## Converts true isometric coordinates to staggered isometric
func get_staggered_from_true(grid_pos: Vector2i) -> Vector2i:
	#[not tested]
	var x = grid_pos.x
	var z = grid_pos.y
	var new_z = x + z
	var z_corrected = z + (1 if new_z % 2 != 0 else 0)
	var new_x = (x - z_corrected) / 2
	return Vector2i(new_x, new_z)

## Converts staggered isometric coordinates to true isometric
func get_true_from_staggered(grid_pos: Vector2i) -> Vector2i:
	var x = grid_pos.x
	var z = grid_pos.y 
	var new_x = z + x - z/2
	var new_z = z - x - z/2
	if z % 2 != 0: 
		new_z -= 1
	return Vector2i(new_x, new_z)
#endregion

#region Grid-world transformations
## Converts grid coordinates to world position (staggered)
func grid_to_world(grid_pos: Vector2i) -> Vector3:
	var world_pos: Vector2i = get_true_from_staggered(grid_pos)
	return Vector3(world_pos.x * cell_size.x, 0, world_pos.y * cell_size.y)

## Converts grid coordinates to world position (true isometric)
func grid_to_world_true(grid_pos: Vector2i) -> Vector3:
	return Vector3(grid_pos.x * cell_size.x, 0, grid_pos.y * cell_size.y)

## Converts world position to grid coordinates (staggered)
func world_to_grid(world_pos: Vector3) -> Vector2i:
	var true_cords:Vector2 = world_to_grid_true(world_pos)
	return get_staggered_from_true(true_cords)

## Converts world position to grid coordinates (true isometric)
func world_to_grid_true(world_pos: Vector3) -> Vector2i:
	assert(cell_size != Vector2.ZERO, "Cell size cannot be zero")
	var true_cords:Vector2 = Vector2(world_pos.x / cell_size.x, world_pos.z / cell_size.y)
	return Vector2i(true_cords)
#endregion

#region Grid object manipulations
## Places a grid object at specified position (staggered coords)
func set_cell_item(pos: Vector2i, grid_object: Node) -> void:
	if grid_object is not GridObject:
		return
	
	if has_cell_item(pos):
		remove_cell_item(pos)
		
	grid_object._cell_position = pos
	grid_object._cell_true_position = get_true_from_staggered(pos)
	var world_pos: Vector3 = grid_to_world_true(grid_object._cell_true_position)
	grid_object.position = world_pos
	grid_object._world_position = Vector2(world_pos.x, world_pos.z)
	grid_object.name = "GridObject_%d_%d" % [pos.x, pos.y]
	add_child(grid_object)
	_grid_objects[pos] = grid_object

## Places a grid object at specified position (true isometric coords)
func set_cell_item_true(pos: Vector2i, grid_object: Node) -> void:
	if grid_object is not GridObject:
		return
	
	var staggered_pos = get_staggered_from_true(pos)
	set_cell_item(staggered_pos, grid_object)

## Removes object from cell (staggered coords)
func remove_cell_item(pos: Vector2i) -> void:
	_remove_cell_item_impl(pos)

## Removes object from cell (true isometric coords)
func remove_cell_item_true(pos: Vector2i) -> void:
	_remove_cell_item_impl(get_staggered_from_true(pos))

func _remove_cell_item_impl(pos: Vector2i) -> void:
	if has_cell_item(pos):
		var obj = _grid_objects[pos]
		if obj is GridObject and not is_instance_valid(obj.get_parent()):
			_on_child_exiting(obj)
			remove_child(obj)
			obj.queue_free()

## Checks if cell contains an object (staggered coords)
func has_cell_item(pos: Vector2i) -> bool:
	return pos in _grid_objects and is_instance_valid(_grid_objects[pos])

## Checks if cell contains an object (true isometric coords)
func has_cell_item_true(pos: Vector2i) -> bool:
	return has_cell_item(get_staggered_from_true(pos))

## Gets object at cell position (staggered coords)
func get_cell_item(pos: Vector2i) -> Node:
	return _grid_objects.get(pos)

## Gets object at cell position (true isometric coords)
func get_cell_item_true(pos: Vector2i) -> Node:
	return get_cell_item(get_staggered_from_true(pos))

## Updates all children positions when cell size changes
func _update_children() -> void:
	#[not tested]
	for pos in _grid_objects:
		var obj = _grid_objects[pos]
		if is_instance_valid(obj):
			obj.position = grid_to_world(pos)
			obj._world_position = Vector2(obj.position.x, obj.position.z)

## Returns 8 neighboring cells (orthogonal + diagonal) (staggered)
func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []

	var offsets_odd: Array[Vector2i] = [
		Vector2i(0, -1), 
		Vector2i(1, -1), 
		Vector2i(0, -2),
		
		Vector2i(0, 2),
		Vector2i(0, 1), 
		Vector2i(1, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
	]
	var offsets_even: Array[Vector2i] = [
		Vector2i(0, -1), 
		Vector2i(-1, -1),
		Vector2i(0, -2),
		
		Vector2i(0, 2),
		Vector2i(0, 1), 
		Vector2i(-1, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
	]
	
	var offsets = offsets_even if pos.y % 2 == 0 else offsets_odd
	
	for offset in offsets:
		var neighbor_pos = pos + offset
		if has_cell_item(neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors

#endregion
