extends Node3D

@export var world_size: Vector2i = Vector2(9,18)
@export_group("Grid")
@export var cell_size: Vector2 = Vector2(1.05, 1.05)

const TILE_SCENE = preload("res://src/tiles/tile.tscn")
var grid_map: OrthoGridMap

func _ready() -> void:
	grid_map = OrthoGridMap.new()
	grid_map.name = "MainGridMap"
	grid_map.cell_size = cell_size
	add_child(grid_map)
	spawn_grid()

func spawn_grid() -> void:
	for y in world_size.y-1:
		for x in world_size.x:
			if y % 2 != 0 and x == world_size.x - 1:
				continue 
			var grid_object = TILE_SCENE.instantiate()
			var grid_pos = Vector2i(x, y)
			grid_map.set_cell_item(grid_pos, grid_object)
			
			#await get_tree().create_timer(0.05).timeout
