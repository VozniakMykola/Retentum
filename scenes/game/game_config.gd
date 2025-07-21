class_name GameConfig
extends Resource

@export_category("From Difficulty Adjuster")
@export var world_x: int
@export var world_size: Vector2i
@export var missing_tiles_rate: float
@export var endgame_tiles_rate: float
@export var endgame_shore: int
@export var monke_spawn_area: int
@export_category("From Narration Adjuster")
@export var biome: G.BiomeType
@export var world_shape: G.ShapePattern
@export var chalk_tiles_rate: float
@export var chalk_inventory_count: int

static func generate_config() -> GameConfig:
	var config = GameConfig.new()
	
	#From Difficulty Adjuster
	var difficulty = DifficultyAdjuster.get_data()

	config.world_x = randi_range(difficulty.world_x_size_range.x, difficulty.world_x_size_range.y)
	config.world_size = Vector2i(config.world_x, config.world_x*2)
	config.endgame_shore = difficulty.endgame_shore
	config.monke_spawn_area = difficulty.monke_spawn_area

	config.missing_tiles_rate = randi_range(difficulty.missing_tiles_rate.x, difficulty.missing_tiles_rate.y)
	config.endgame_tiles_rate = randi_range(difficulty.endgame_tiles_rate.x, difficulty.endgame_tiles_rate.y)
	
	#From Narration Adjuster
	var narration = NarrationAdjuster.get_data()
	config.biome = narration.biome
	config.world_shape = narration.world_shape
	config.chalk_inventory_count = narration.chalk_inventory_count
	
	config.chalk_tiles_rate = narration.chalk_tiles_rate
	
	return config
