extends Node

const GRID_X_MAX = 20
const TILE_SCENE = preload("res://src/tiles/tile.tscn")
const WORLD_PATH = "user://saved_world.tscn"

var grid_map: OrthoGridMap = null
var thread: Thread = null
var is_generating = false

func _ready():
	initialize_grid()

func initialize_grid():
	if grid_map == null:
		grid_map = OrthoGridMap.new()
		grid_map.cell_size = Vector2(1.05, 1.05)
		thread = Thread.new()
		thread.start(_generate_tiles_in_thread)

func _generate_tiles_in_thread():
	is_generating = true
	for y in GRID_X_MAX * G.Y_RATIO:
		for x in GRID_X_MAX:
			var tile = TILE_SCENE.instantiate()
			tile.tile_config = TileConfig.new()
			call_deferred("_add_tile_to_grid", Vector2i(x, y), tile)
	thread.wait_to_finish()
	thread = null
	is_generating = false

func _add_tile_to_grid(position: Vector2i, tile: Node):
	grid_map.set_cell_item(position, tile)
	print("punk")

func _exit_tree():
	if thread != null && thread.is_active():
		thread.wait_to_finish()

func reset_tiles():
	for position in grid_map._grid_objects:
		var tile = grid_map._grid_objects[position]
		tile.tile_config = TileConfig.new()
