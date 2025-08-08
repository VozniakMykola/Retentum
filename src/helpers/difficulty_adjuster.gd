class_name DifficultyAdjuster
extends Resource

@export var world_x_size_range: int = 9
@export var missing_tiles_rate: float = 0.3
@export var endgame_tiles_rate: float = 0.5
@export var endgame_shore: int = 1
@export var monke_spawn_area: int = 1
@export var world_shape: G.ShapePattern

static func get_data() -> DifficultyAdjuster:
	var config = DifficultyAdjuster.new()
	
	config.missing_tiles_rate = 0.3
	config.endgame_shore = 2
	config.monke_spawn_area = 2

	match P.get_current_pacing_state():
		P.PacingState.EASY:
			config.world_x_size_range = 15
		P.PacingState.MEDIUM:
			config.world_x_size_range = 12
		P.PacingState.HARD:
			config.world_x_size_range = 9
		P.PacingState.CLIMAX:
			config.world_x_size_range = 9
	
	#very hardcoded but but
	var world_size_rate_coef = (POOLGRID.GRID_X_MAX - config.world_x_size_range) * 0.03
	var world_size_shore_coef = (POOLGRID.GRID_X_MAX - config.world_x_size_range) / 3
	
	config.world_shape = randi() % G.ShapePattern.size()
	match config.world_shape:
		G.ShapePattern.RECTANGLE:
			config.endgame_tiles_rate = 0.3 - world_size_rate_coef
		G.ShapePattern.DIAMOND:
			config.endgame_tiles_rate = 0.3 - world_size_rate_coef
		G.ShapePattern.CIRCLE:
			config.endgame_tiles_rate = 0.4 - world_size_rate_coef
		G.ShapePattern.CROSS:
			config.endgame_tiles_rate = 0.4 - world_size_rate_coef
		G.ShapePattern.ISLAND:
			config.endgame_tiles_rate = 0.6 - world_size_rate_coef
			config.missing_tiles_rate = 0.1
			config.endgame_shore = 3
	
	config.endgame_shore -= world_size_shore_coef
	
	return config
