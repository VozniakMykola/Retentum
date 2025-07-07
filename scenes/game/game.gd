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
	var field_data = GC.create_game()
	for coord in field_data:
		var tile = field_data[coord]
		var grid_object = TILE_SCENE.instantiate()
		grid_object.tile_data = tile
		grid_map.set_cell_item(Vector2i(coord.x, coord.y), grid_object)


func _on_lose_pressed() -> void:
	G.session_ended(false)

func _on_win_pressed() -> void:
	G.session_ended(true)
