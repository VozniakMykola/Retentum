class_name GameBuilder
extends Node

var shape_mapper: ShapeMapper
var terrain_mapper: TerrainMapper
var current_config: GameConfig

func _init():
	shape_mapper = ShapeMapper.new()
	terrain_mapper = TerrainMapper.new()

func generate_config() -> GameConfig:
	current_config = GameConfig.generate_config()
	return current_config
	
func generate_level() -> Dictionary:
	if !current_config:
		print("[!] Use generate_config() before generate_level()")
		return {}
	
	#stage 1 - Shape
	var shaped_island = shape_mapper.create_shape(G.ShapePattern.RECTANGLE, current_config.world_size, current_config.endgame_shore, current_config.monke_spawn_area)
	#current_config.world_shape NOOO LA POLICIA
	#stage 2 - Biome
	#var biome = G.BIOME_RESOURCES[G.BiomeType.PLAZA] #DELETE THIS
	var biome = G.BIOME_RESOURCES[current_config.biome]
	var random_pattern = biome.get_random_pattern()
	var palette = biome.tiles_palette
	var biomed_island = terrain_mapper.map_terrain(random_pattern, palette, shaped_island, biome.is_sequentially)
	
	#stage 3 - Endgames & Missing tiles
	var gamified_island = scatter_game_objects(biomed_island, shaped_island)
	
	#stage 4 - Monke
	
	return gamified_island

func scatter_game_objects(tile_configs: Dictionary, markup: Array) -> Dictionary:
	for y in range(markup.size()):
		for x in range(markup[y].size()):
			if markup[y][x] == G.GenCellType.EDGE:
				if randf_range(0.0, 1.0) <= current_config.endgame_tiles_rate:
					var rand_y_offset = randi_range(current_config.endgame_shore * -G.Y_RATIO, current_config.endgame_shore * G.Y_RATIO)
					var rand_x_offset = randi_range(-current_config.endgame_shore, current_config.endgame_shore)
					if  tile_configs.has(Vector2i(x+rand_x_offset, y+rand_y_offset)):
						tile_configs[Vector2i(x+rand_x_offset, y+rand_y_offset)].tile_type = G.TileType.ENDGAME
					else:
						tile_configs[Vector2i(x, y)].tile_type = G.TileType.ENDGAME
			elif markup[y][x] == G.GenCellType.LAND && P.unlocked_chalks.size() != 0:
				if randf_range(0.0, 100.0) <= current_config.chalk_tiles_rate:
					tile_configs[Vector2i(x, y)].tile_type = G.TileType.CHALKED
					if P.last_unlocked_chalk != null:
						tile_configs[Vector2i(x, y)].chalk_type = P.last_unlocked_chalk
					else:
						tile_configs[Vector2i(x, y)].chalk_type = P.unlocked_chalks.pick_random()
					if tile_configs[Vector2i(x, y)].chalk_type == G.ChalkType.GUIDANCE:
						tile_configs[Vector2i(x, y)].guidance_vec = G.get_random_direction()
	return tile_configs

#@export_category("From Difficulty Adjuster")
#@export var world_x: int

#@export var missing_tiles_count: int
#@export var endgame_tiles_count: int
#@export var deviation_threshold: int


#@export var monke_center_spawn: bool
#@export_category("From Narration Adjuster")
#@export var chalk_tiles_count: int
#@export var chalk_inventory_count: int
