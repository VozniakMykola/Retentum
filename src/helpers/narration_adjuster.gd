class_name NarrationAdjuster
extends Resource

@export var biome: G.BiomeType
@export var world_shape: G.ShapePattern
@export var chalk_tiles_count: int
@export var chalk_inventory_count: int


static func get_data() -> NarrationAdjuster:
	var config = NarrationAdjuster.new()
	
	config.biome = _select_biome()
	config.world_shape = randi() % G.ShapePattern.size()
	
	return config


#even if the sequence has been completed, the new biome will still only be visible to the player after a successful game
#a new biome is shown for half of the pacing sequence and then a random one
static func _select_biome() -> G.BiomeType:
	if P.last_unlocked_biome != null:
		if (P.current_win_streak > 0 || P.is_last_unlocked_biome_played):
			P.is_last_unlocked_biome_played = true
			return P.last_unlocked_biome
		else:
			var available_biomes = P.unlocked_biomes.duplicate()
			available_biomes.erase(P.last_unlocked_biome)
			return available_biomes[randi() % available_biomes.size()]
	else:
		return P.unlocked_biomes.pick_random()
