class_name GameBuilder
extends Node

var shape_mapper: ShapeMapper
var terrain_mapper: TerrainMapper
var current_config: GameConfig

func _init():
	shape_mapper = ShapeMapper.new()
	terrain_mapper = TerrainMapper.new()

func start_new_game() -> GameConfig:
	current_config = GameConfig.generate_config()
	return current_config
	
func generate_level(config: GameConfig) -> Dictionary:
	var biome = G.BIOME_RESOURCES[config.biome]
	#var biome = G.BIOME_RESOURCES[G.BiomeType.PLAZA] #DELETE THIS
	var shaped_raw = shape_mapper.create_shape(config.world_shape, config.world_size)
	var random_pattern = biome.get_random_pattern()
	var palette = biome.tiles_palette
	var patterned_raw = terrain_mapper.map_terrain(random_pattern, palette, shaped_raw, biome.is_sequentially)
	return patterned_raw
