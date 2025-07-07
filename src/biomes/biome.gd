extends Resource
class_name Biome

@export var biome_id: String = ""

@export_group("Visual")
@export var tiles_palette: Array[TileResource] = []
@export var terrain_patterns: Array[G.TerrainPattern] = []
@export_group("Visual 2")
@export var biome_decor: Array[PackedScene] = [] 
@export var biome_environment: Array[PackedScene] = []
@export_group("Journal")
@export var is_unlocked: bool = false
@export var required_wins: int = 0

func get_random_palette_tile() -> TileResource:
	return tiles_palette.pick_random()

func get_random_pattern() -> G.TerrainPattern:
	return terrain_patterns.pick_random()

#func generate_field() -> Array:
	#terrain_patterns.pick_random()
	#if terrain_pattern:
		#return terrain_pattern.generate()
	#return []

#@export_group("Visuals")
#@export var voidbox: Texture
#@export var radiance_color: Color = Color.WHITE

#@export_group("Audio")
#@export var ambient_sounds: Array[AudioStream] = []
#@export var music_track: AudioStream

#@export_group("Journal")
#@export var display_name: String = "Unnamed Biome"
#@export var icon: Texture2D
#@export var description: String = ""
