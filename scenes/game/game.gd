extends Node3D

@export_group("Game")
var game_builder: GameBuilder = GameBuilder.new()
var game_config: Dictionary
@export_group("Grid")
@export var cell_size: Vector2 = Vector2(1.05, 1.05)

const TILE_SCENE = preload("res://src/tiles/tile.tscn")
const GAME_SCENE = preload("res://scenes/game/game.tscn") 
var grid_map: OrthoGridMap

func _ready() -> void:
	initialize_game()

func initialize_game() -> void:
	game_config = game_builder.start_new_game()
	
	grid_map = OrthoGridMap.new()
	grid_map.name = "MainGridMap"
	grid_map.cell_size = cell_size
	add_child(grid_map)
	
	generate_level()

func generate_level():
	for coord in game_config:
		var tile = game_config[coord]
		var grid_object = TILE_SCENE.instantiate()
		grid_object.tile_data = tile
		grid_map.set_cell_item(Vector2i(coord.x, coord.y), grid_object)

func restart_game() -> void:
	var new_game = GAME_SCENE.instantiate()
	get_tree().root.add_child(new_game)
	get_tree().current_scene = new_game
	queue_free()

func _on_win_pressed() -> void:
	P.record_session_result(true)
	restart_game()

func _on_lose_pressed() -> void:
	P.record_session_result(false)
	restart_game()
