extends Node
#pacer & progressor

#Neutral
var world_shape: G.ShapePattern
var biome: Biome #for terrain_patterns and tiles_palette
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

func create_game():
	get_pacing_settings()
	get_progress_settings()

func get_progress_settings():
	pass

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
