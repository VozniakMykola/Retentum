extends Node3D

#const TILE_SCENE: PackedScene = preload("res://libs/ortho_grid_map/grid_object.tscn")
const TILE_SCENE = preload("res://src/tile/tile.tscn")
@onready var tile_map: Node3D = $TileMap
const GRID_SIZE: int = 9
var tile_size: int
var grid_map: OrthoGridMap

func _ready() -> void:
	grid_map = OrthoGridMap.new()
	grid_map.y_index = 2
	grid_map.cell_size = Vector2(1, 1)
	add_child(grid_map)
	spawn_just_grid_zov()

func spawn_just_grid_zov() -> void:
	for y in GRID_SIZE*2-1:
		for x in GRID_SIZE:
			if y % 2 != 0 and x == GRID_SIZE - 1:
				continue 
			var grid_object := TILE_SCENE.instantiate()
			var grid_pos = Vector2i(x, y)
			grid_map.set_cell_item(grid_pos, grid_object)
			
			#await get_tree().create_timer(0.05).timeout
