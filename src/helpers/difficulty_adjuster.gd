class_name DifficultyAdjuster
extends Resource

@export var world_x_size_range: Vector2i = Vector2i(9, 9)
@export var missing_tiles_rate: Vector2 = Vector2(0, 0.33)
@export var endgame_tiles_rate: Vector2 = Vector2(0.8, 1.0)
@export var endgame_shore: int = 1
@export var monke_spawn_area: int = 1

static func get_data() -> DifficultyAdjuster:
	var config = DifficultyAdjuster.new()
	
	match P.get_current_pacing_state():
		P.PacingState.EASY:
			config.world_x_size_range = Vector2i(16, 20)
			config.missing_tiles_rate = Vector2i(0.15, 0.4)
			config.endgame_tiles_rate = Vector2i(0.5, 8.0)
			config.endgame_shore = 1
			config.monke_spawn_area = 1
			
		P.PacingState.MEDIUM:
			config.world_x_size_range = Vector2i(12, 15)
			config.missing_tiles_rate = Vector2i(0.1, 0.33)
			config.endgame_tiles_rate = Vector2i(0.65, 9.0)
			config.endgame_shore = 1
			config.monke_spawn_area = 2
			
		P.PacingState.HARD:
			config.world_x_size_range = Vector2i(9, 11)
			config.missing_tiles_rate = Vector2i(0, 0.2)
			config.endgame_tiles_rate = Vector2i(0.75, 9.0)
			config.endgame_shore = 3
			config.monke_spawn_area = 3
			
		P.PacingState.CLIMAX:
			config.world_x_size_range = Vector2i(6, 9)
			config.missing_tiles_rate = Vector2i(0, 0.1)
			config.endgame_tiles_rate = Vector2i(0.8, 1.0)
			config.endgame_shore = 2
			config.monke_spawn_area = 3

	
	return config
