class_name GameBuilder
extends Node

var shape_mapper: ShapeMapper
var terrain_mapper: TerrainMapper
var current_config: GameConfig
var centers: Array

func _init():
	shape_mapper = ShapeMapper.new()
	terrain_mapper = TerrainMapper.new()

func generate_config() -> GameConfig:
	current_config = GameConfig.generate_config()
	return current_config
	
func generate_field() -> Dictionary:
	if !current_config:
		print("[!] Use generate_config() before generate_level()")
		return {}
	
	#stage 1 - Shape
	var shaped_island = shape_mapper.create_shape(current_config.world_shape, current_config.world_size, current_config.endgame_shore, current_config.monke_spawn_area)
	
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
			var cell_type: int = markup[y][x]
			var cell_pos: Vector2i = Vector2i(x, y)
			if tile_configs.has(cell_pos):
				var tile_conf = tile_configs[cell_pos]
				tile_conf.tile_type = G.TileType.NORMAL
				match cell_type:
					G.GenCellType.VOID, G.GenCellType.SHORE:
						pass
					G.GenCellType.EDGE:
						if randf() <= current_config.endgame_tiles_rate:
							var rand_y_offset: int = randi_range(current_config.endgame_shore * -G.Y_RATIO, current_config.endgame_shore * G.Y_RATIO)
							var rand_x_offset: int = randi_range(-current_config.endgame_shore, current_config.endgame_shore)
							var target_pos: Vector2i = Vector2i(x + rand_x_offset, y + rand_y_offset)
							
							if tile_configs.has(target_pos) and markup[target_pos.y][target_pos.x] == G.GenCellType.SHORE:
								tile_configs[target_pos].tile_type = G.TileType.ENDGAME
							else:
								tile_conf.tile_type = G.TileType.ENDGAME
					G.GenCellType.LAND:
						var random_modifier: bool = (randi() % 2) == 0
						if random_modifier:
							if P.unlocked_chalks.size() > 0 and randf_range(0.0, 100.0) <= current_config.chalk_tiles_rate:
								tile_conf.tile_type = G.TileType.CHALKED
								tile_conf.chalk_type = P.last_unlocked_chalk if P.last_unlocked_chalk != null else P.unlocked_chalks.pick_random()
								if tile_conf.chalk_type == G.ChalkType.GUIDANCE:
									tile_conf.guidance_vec = Direction2D.get_random()
						else:
							if randf() <= current_config.missing_tiles_rate:
								tile_conf.tile_type = G.TileType.DEAD
					G.GenCellType.CENTER:
						centers.append(cell_pos)
					_:
						print("GameBuilder: Mapping Error")
	return tile_configs
