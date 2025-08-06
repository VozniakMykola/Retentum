extends Node

const GRID_X_MAX: int = 20
const GRID_Y_MAX: int = GRID_X_MAX * G.Y_RATIO
const TILE_SCENE = preload("res://scenes/tile/tile.tscn")

var grid_map: OrthoGridMap = null
var thread: Thread = null
var is_generating: bool = false

func _ready():
	is_generating = true
	initialize_grid()

func initialize_grid():
	if grid_map != null:
		return
	grid_map = OrthoGridMap.new()
	#grid_map.cell_size = Vector2(1.05, 1.05)
	grid_map.cell_size = Vector2(0.99, 0.99)
	grid_map.name = "GameField"
	if thread == null or not thread.is_started():
		thread = Thread.new()
		thread.start(_generate_tiles_in_thread)

func _generate_tiles_in_thread():
	var tiles_to_add: Array = []
	for y in GRID_Y_MAX:
		for x in GRID_X_MAX:
			var tile = TILE_SCENE.instantiate()
			tiles_to_add.append({
				position = Vector2i(x, y),
				instance = tile
			})
	call_deferred("_add_batch", tiles_to_add)

func _add_batch(tiles: Array) -> void:
	for item in tiles:
		grid_map.set_cell_item(item.position, item.instance)
	if thread != null:
		thread.wait_to_finish()
		thread = null
	is_generating = false

func _exit_tree():
	if thread != null and thread.is_active():
		thread.wait_to_finish()
		thread = null

func reset_tiles():
	for position in grid_map._grid_objects:
		var tile = grid_map._grid_objects[position]
		tile.tile_config = TileConfig.new()
