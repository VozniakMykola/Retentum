class_name Monke
extends Node3D

@export var grid_map: OrthoGridMap
@export var current_cell: Vector2i
@export var current_tile: Tile

var endgame_tiles: Array[Vector2i] = []
var path_thread: Thread
var calculated_path: Array
var is_calculating: bool = false
const MOVE_SPEED: float = 8

func _ready():
	path_thread = Thread.new()

func init() -> void:
	set_world_position()
	find_endgames()

func _exit_tree():
	if path_thread.is_started():
		path_thread.wait_to_finish()

func set_world_position(cell: Vector2i = current_cell) -> void:
	position = grid_map.grid_to_world(cell)
	if grid_map.has_cell_item(cell):
		current_tile = grid_map.get_cell_item(cell) as Tile
		current_tile.set_tile_state(G.TileState.OCCUPIED)

func find_endgames() -> void:
	endgame_tiles.clear()
	for cell in grid_map._grid_objects:
		var tile: Tile = grid_map.get_cell_item(cell)
		if tile.tile_core.tile_type == G.TileType.ENDGAME:
			endgame_tiles.append(cell)

func monke_turn() -> void:
	if is_calculating:
		return
	is_calculating = true
	calculated_path = []
	
	if path_thread.is_started():
		path_thread.wait_to_finish()
	
	path_thread.start(_threaded_find_closest_endgame)

func _threaded_find_closest_endgame() -> void:
	calculated_path = find_closest_endgame_with_path_A_STAR()
	is_calculating = false
	call_deferred("move_to_endgame")

func move_to_endgame():
	if calculated_path.size() > 1:
		move_to(calculated_path[1])
	else:
		print("A2")
		move_random()
		

func move_random():
	var valid_neighbors = grid_map.get_neighbors(current_cell).filter(
		func(neighbor):
			var tile = grid_map.get_cell_item(neighbor) as Tile
			return (tile.tile_core.tile_type != G.TileType.DEAD and tile.tile_core.tile_type != G.TileType.NULL)
	)
	
	if valid_neighbors.size() > 0:
		move_to(valid_neighbors.pick_random())
	else:
		get_parent()._on_win_pressed()

#################################################################
func move_to(next_cell: Vector2i) -> void:
	var dir: Vector2i = (grid_map.get_true_from_staggered(next_cell) - grid_map.get_true_from_staggered(current_cell))
	var normalized_dir: Vector2i = Direction2D.get_rotated(dir, -2)
	var rotation_deg = Direction2D.direction_to_degrees(normalized_dir)
	rotation_degrees = Vector3(0, rotation_deg, 0)
	
	if grid_map.has_cell_item(next_cell):
		current_tile.set_tile_state(G.TileState.EMPTY)
		current_cell = next_cell
		current_tile = grid_map.get_cell_item(current_cell) as Tile
		current_tile.set_tile_state(G.TileState.OCCUPIED)
		await move_anim_1()
		match current_tile.tile_core.tile_type:
			G.TileType.CHALKED:
				print("Monke stepped on chalked tile!")
			G.TileType.ENDGAME:
				print("Monke reached endgame!")
				get_parent()._on_lose_pressed()
			_:
				pass
	G.set_turn(G.GameTurn.PLAYER_TURN)

func move_anim_1():
	var tween = create_tween()
	tween.tween_property(self, "position", grid_map.grid_to_world(current_cell), 1.0 / MOVE_SPEED)
	await tween.finished
#################################################################

func find_closest_endgame_with_path_A_STAR() -> Array:
	var closest_tile = null
	var best_path = []
	var min_steps = INF
	
	for target in endgame_tiles:
		var path = find_path_A_STAR(current_cell, target)
		if path.size() > 0 and path.size() < min_steps:
			min_steps = path.size()
			closest_tile = target
			best_path = path
	
	return best_path

func find_path_A_STAR(start: Vector2i, end: Vector2i) -> Array:
	#A* algorithm
	var astar = AStar2D.new()
	var points = {}
	var point_id = 0
	
	#Add all tiles, ignore NULL and DEAD
	for cell in grid_map._grid_objects:
		var tile = grid_map.get_cell_item(cell)
		if tile.tile_core.tile_type != G.TileType.NULL and tile.tile_core.tile_type != G.TileType.DEAD:
			var id = point_id
			point_id += 1
			astar.add_point(id, Vector2(cell.x, cell.y))
			points[cell] = id
	
	#Add connections
	for cell in points:
		var neighbors = grid_map.get_neighbors(cell)
		for neighbor in neighbors:
			if points.has(neighbor):
				var from_id = points[cell]
				var to_id = points[neighbor]
				if not astar.are_points_connected(from_id, to_id):
					var cost = Vector2(cell).distance_to(Vector2(neighbor))
					cost += randf_range(-0.4, 0.4) #monke stupidity factor
					astar.connect_points(from_id, to_id, cost)
	
	#Path find
	if points.has(start) and points.has(end):
		var start_id = points[start]
		var end_id = points[end]
		var point_path = astar.get_point_path(start_id, end_id)
		
		#Map to  Vector2i
		var cell_path = []
		for point in point_path:
			cell_path.append(Vector2i(point))
		return cell_path
	
	return []
