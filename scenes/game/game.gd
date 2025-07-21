extends Node3D

@export_group("Game")
var game_builder: GameBuilder = GameBuilder.new()
var game_config: GameConfig
var level_map: Dictionary

@onready var grid_map: OrthoGridMap = $MainGridMap

const TILE_SCENE = preload("res://src/tiles/tile.tscn")
const GAME_SCENE = preload("res://scenes/game/game.tscn") 

func _ready() -> void:
	initialize_game()

func initialize_game() -> void:
	game_config = game_builder.generate_config()
	level_map = game_builder.generate_level()
	generate_level()

func generate_level():
	var all_coords = level_map.keys()
	all_coords.shuffle()
	
	#game_config.world_x * (game_config.world_x * 2) / 10
	var batch_size: int = game_config.world_x / 2
	var delay_between_batches = 0.02

	for i in range(0, all_coords.size(), batch_size):
		var end_index = min(i + batch_size, all_coords.size())
		var batch_coords = all_coords.slice(i, end_index)
		for coord in batch_coords:
			var tile = TILE_SCENE.instantiate()
			tile.tile_config = level_map[coord]
			grid_map.set_cell_item(coord, tile)

		await get_tree().create_timer(delay_between_batches).timeout

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
