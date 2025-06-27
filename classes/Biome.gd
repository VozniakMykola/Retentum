extends Resource
class_name Biome

@export var biome_id: String = ""

@export_group("Visuals")
@export var biome_decor: Array[PackedScene] = [] 
@export var biome_environment: Array[PackedScene] = []
@export var tiles_palette: Array[PackedScene] = []

@export_group("Gameplay")
@export var terrain_pattern: FastNoiseLite

@export_group("Special")
@export var is_unlocked: bool = false
@export var required_wins: int = 0

func get_random_tile_material() -> PackedScene:
	return tiles_palette.pick_random()

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
