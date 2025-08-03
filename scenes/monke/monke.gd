class_name Monke
extends Node3D

@export var grid_map: OrthoGridMap
@export var current_cell: Vector2i

var move_timer: Timer
const MOVE_SPEED: float = 2.0

func _ready():
	move_timer = Timer.new()
	move_timer.wait_time = 2.0
	move_timer.timeout.connect(_on_move_timer_timeout)
	add_child(move_timer)
	move_timer.start()

func _on_move_timer_timeout():
	try_move_to_random_neighbor()

func init():
	update_world_position()

func update_world_position():
	var world_pos = grid_map.grid_to_world(current_cell)
	position = world_pos

func handle_tile_type():
	if grid_map.has_cell_item(current_cell):
		var tile = grid_map.get_cell_item(current_cell) as Tile
		#tile.set_tile_state(G.TileState.OCCUPIED)
		match tile.tile_core.tile_type:
			G.TileType.CHALKED:
				print("Monke stepped on chalked tile!")
			G.TileType.ENDGAME:
				print("Monke reached endgame!")
				get_parent()._on_lose_pressed()
			_:
				pass

func try_move_to_random_neighbor():
	var neighbors = grid_map.get_neighbors(current_cell)
	var valid_neighbors = []
	
	for neighbor in neighbors:
		var tile = grid_map.get_cell_item(neighbor) as Tile
		if tile.tile_core.tile_type != G.TileType.DEAD && tile.tile_core.tile_type != G.TileType.NULL:
			valid_neighbors.append(neighbor)
	
	if valid_neighbors.size() > 0:
		var random_index = randi() % valid_neighbors.size()
		current_cell = valid_neighbors[random_index]

		var target_pos = grid_map.grid_to_world(current_cell)
		var tween = create_tween()
		tween.tween_property(self, "position", target_pos, 1.0 / MOVE_SPEED)
		await tween.finished
		handle_tile_type()
	else:
		get_parent()._on_win_pressed()
