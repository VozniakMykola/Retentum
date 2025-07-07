extends Node
#Global GC

#pacer & progressor

#Neutral
var world_shape: G.ShapePattern
var biome: Biome = G.biome_progress["unlocked"][0]
var chalk_tiles_count: int = 2
var chalk_inventory_count: int = 2
#Pacing
var world_size: Vector2i = Vector2(9, 18)
var missing_tiles_count: int = 2
var endgame_tiles_count: int = 5
var deviation_threshold: int = 1 #for monke and endgames
var monke_center_spawn: bool = true

var shape_mapper = ShapeMapper.new()
var terrain_mapper = TerrainMapper.new()

func _ready():
	pass

func create_game() -> Dictionary:
	get_pacing_settings()
	get_world_shape()
	get_biome()
	#get_chalk_count()
	#get inventory_chalk_count()
	return create_level()

func create_level() -> Dictionary:
	var shaped_raw: Array = shape_mapper.create_shape(world_shape, world_size)
	var random_pattern = biome.get_random_pattern()
	var palette: Array[TileResource] = biome.tiles_palette
	var terrained_raw: Dictionary = terrain_mapper.map_terrain(random_pattern, palette, shaped_raw)
	return terrained_raw

func get_world_shape():
	world_shape = randi() % G.ShapePattern.size()

func get_biome():
	if G.current_win_streak > 0:
		if G.biome_progress["last_unlocked"]:
			biome = G.biome_progress["last_unlocked"]
		else:
			biome = G.biome_progress["unlocked"].pick_pandom()
	else:
		var biome = G.biome_progress["unlocked"].filter(func(b): return b != G.biome_progress["last_unlocked"])

func get_pacing_settings():
	var pacing_state = G.current_pacing_state
	
	# World Size
	var ws_data = world_size_pace[pacing_state]
	world_size = Vector2i(
		randf_range(ws_data["min_size"].x, ws_data["max_size"].x),
		randf_range(ws_data["min_size"].y, ws_data["max_size"].y)
	)
	
	# Missing Tiles
	var miss_data = missing_tiles_count_pace[pacing_state]
	missing_tiles_count = randi_range(miss_data["min_size"], miss_data["max_size"])
	
	# Endgame Tiles
	var end_data = endgame_tiles_count_pace[pacing_state]
	endgame_tiles_count = randi_range(end_data["min_size"], end_data["max_size"])
	
	# Other
	deviation_threshold = deviation_threshold_pace[pacing_state]
	monke_center_spawn = monke_center_spawn_pace[pacing_state]

#y = x*2 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
var world_size_pace = {
	G.PacingState.EASY: { "min_size": Vector2(9, 18), "max_size": Vector2(9, 18) },
	G.PacingState.MEDIUM: { "min_size": Vector2(9, 18), "max_size": Vector2(9, 18) },
	G.PacingState.HARD: { "min_size": Vector2(9, 18), "max_size": Vector2(9, 18) },
	G.PacingState.CLIMAX: { "min_size": Vector2(9, 18), "max_size": Vector2(9, 18) },
}

var missing_tiles_count_pace = {
	G.PacingState.EASY: { "min_size": 6, "max_size": 8 },
	G.PacingState.MEDIUM: { "min_size": 3, "max_size": 5 },
	G.PacingState.HARD: { "min_size": 2, "max_size": 3 },
	G.PacingState.CLIMAX: { "min_size": 0, "max_size": 2 },
}

var endgame_tiles_count_pace = {
	G.PacingState.EASY: { "min_size": 5, "max_size": 10 },
	G.PacingState.MEDIUM: { "min_size": 10, "max_size": 16 },
	G.PacingState.HARD: { "min_size": 10, "max_size": 16 },
	G.PacingState.CLIMAX: { "min_size": 15, "max_size": 20 },
}

var deviation_threshold_pace = {
	G.PacingState.EASY: 0,
	G.PacingState.MEDIUM: 1,
	G.PacingState.HARD: 2,
	G.PacingState.CLIMAX: 3,
}

var monke_center_spawn_pace = {
	G.PacingState.EASY: true,
	G.PacingState.MEDIUM: true,
	G.PacingState.HARD: false,
	G.PacingState.CLIMAX: false,
}
