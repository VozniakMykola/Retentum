extends Node

const GRID_X_MAX = 20
const TILE_SCENE = preload("res://src/tiles/tile.tscn")
const WORLD_PATH = "user://saved_world.tscn"

var grid_map: OrthoGridMap = null

func _ready():
	initialize_grid()

func initialize_grid():
	if grid_map == null:
		grid_map = OrthoGridMap.new()
		grid_map.cell_size = Vector2(1.05, 1.05)
		
		for y in GRID_X_MAX * G.Y_RATIO:
			for x in GRID_X_MAX:
				var tile = TILE_SCENE.instantiate()
				tile.tile_config = TileConfig.new()
				grid_map.set_cell_item(Vector2i(x, y), tile)

func reset_tiles():
	for position in grid_map._grid_objects:
		var tile = grid_map._grid_objects[position]
		tile.tile_config = TileConfig.new()
