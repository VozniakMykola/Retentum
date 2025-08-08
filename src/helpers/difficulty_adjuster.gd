class_name DifficultyAdjuster
extends Resource

@export var world_x_size_range: int = 9
@export var missing_tiles_rate: float = 0.3
@export var endgame_tiles_rate: float = 0.5
@export var endgame_shore: int = 1
@export var monke_spawn_area: int = 1

static func get_data() -> DifficultyAdjuster:
	var config = DifficultyAdjuster.new()
	config.world_x_size_range = 12 # norm
	#config.world_x_size_range = 9 - smol very
	config.missing_tiles_rate = 0.3
	config.endgame_tiles_rate = 0.5
	config.endgame_shore = 1
	config.monke_spawn_area = 2
	#match P.get_current_pacing_state():
		#P.PacingState.EASY:
		#P.PacingState.MEDIUM:
		#P.PacingState.HARD:
		#P.PacingState.CLIMAX:
	
	return config
