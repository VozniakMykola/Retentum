class_name GameConfig
extends Resource

@export_category("From Difficulty Adjuster")
@export var world_size: Vector2i
@export var missing_tiles_count: int
@export var endgame_tiles_count: int
@export var deviation_threshold: int
@export var monke_center_spawn: bool
@export_category("From Narration Adjuster")
@export var biome: G.BiomeType
@export var world_shape: G.ShapePattern
#@export var chalk_tiles_count: int
#@export var chalk_inventory_count: int

static func generate_config() -> GameConfig:
	var config = GameConfig.new()
	
	#From Narration Adjuster
	var narration = NarrationAdjuster.get_data()
	config.biome = narration.biome
	config.world_shape = narration.world_shape
	
	#From Difficulty Adjuster
	var difficulty = DifficultyAdjuster.get_data()
	####!!!!!!!!!!!!!!!##############
	config.world_size = Vector2i(9, 18)  # Fixed for now, expand later
	####!!!!!!!!!!!!!!!##############
	config.missing_tiles_count = randi_range(difficulty.missing_tiles_range.x, difficulty.missing_tiles_range.y)
	config.endgame_tiles_count = randi_range(difficulty.endgame_tiles_range.x, difficulty.endgame_tiles_range.y)
	config.deviation_threshold = difficulty.deviation_threshold
	config.monke_center_spawn = difficulty.monke_center_spawn
	
	return config
