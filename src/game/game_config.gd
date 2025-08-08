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
#@export_category("Other")
#@export var world_center_tile: Vector2i
#@export var world_center: Vector3

static func generate_config() -> GameConfig:
	var config = GameConfig.new()
	
	#From Difficulty Adjuster
	var difficulty = DifficultyAdjuster.get_data()

	config.world_x = difficulty.world_x_size_range
	config.world_size = Vector2i(config.world_x, config.world_x*G.Y_RATIO)
	config.endgame_shore = difficulty.endgame_shore
	config.monke_spawn_area = difficulty.monke_spawn_area
	config.world_shape = difficulty.world_shape
	
	config.missing_tiles_rate = difficulty.missing_tiles_rate
	config.endgame_tiles_rate = difficulty.endgame_tiles_rate
	#From Narration Adjuster
	var narration = NarrationAdjuster.get_data()
	config.biome = narration.biome
	config.chalk_inventory_count = narration.chalk_inventory_count
	config.chalk_tiles_rate = narration.chalk_tiles_rate
	
	return config
