class_name DifficultyAdjuster
extends Resource

@export var world_size_range: Vector2i = Vector2i(9, 9)
@export var missing_tiles_range: Vector2i = Vector2i(2, 5)
@export var endgame_tiles_range: Vector2i = Vector2i(5, 15)
@export var deviation_threshold: int = 1
@export var monke_center_spawn: bool = true

static func get_data() -> DifficultyAdjuster:
	var config = DifficultyAdjuster.new()
	
	match P.get_current_pacing_state():
		P.PacingState.EASY:
			config.missing_tiles_range = Vector2i(6, 8)
			config.endgame_tiles_range = Vector2i(5, 10)
			config.deviation_threshold = 0
			config.monke_center_spawn = true
			config.world_size_range = Vector2i(16, 20)
		P.PacingState.MEDIUM:
			config.missing_tiles_range = Vector2i(3, 5)
			config.endgame_tiles_range = Vector2i(10, 16)
			config.deviation_threshold = 1
			config.monke_center_spawn = true
			config.world_size_range = Vector2i(12, 15)
		P.PacingState.HARD:
			config.missing_tiles_range = Vector2i(2, 3)
			config.endgame_tiles_range = Vector2i(10, 16)
			config.deviation_threshold = 2
			config.monke_center_spawn = false
			config.world_size_range = Vector2i(9, 11)
		P.PacingState.CLIMAX:
			config.missing_tiles_range = Vector2i(0, 2)
			config.endgame_tiles_range = Vector2i(15, 20)
			config.deviation_threshold = 3
			config.monke_center_spawn = false
			config.world_size_range = Vector2i(6, 9)
	
	return config
