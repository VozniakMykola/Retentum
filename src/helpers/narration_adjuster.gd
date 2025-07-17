class_name NarrationAdjuster
extends Resource

@export var biome: G.BiomeType
@export var world_shape: G.ShapePattern
@export var chalk_tiles_rate: float
@export var chalk_inventory_rate: int


static func get_data() -> NarrationAdjuster:
	var config = NarrationAdjuster.new()
	
	config.biome = _select_biome()
	config.world_shape = randi() % G.ShapePattern.size()
	config.chalk_tiles_rate = _set_chalk_rate()
	config.chalk_inventory_rate = _set_chalk_rate() # NOOOO NOOOO LA POLICIA
	return config

static func _set_chalk_rate() -> float:
	var outcomes = [
		[0.02, 0.0, 0.0],      # 1/50 шанс отримати 0
		[0.01, 90.0, 100.0],    # 1/100 шанс отримати 90-100
		[0.97, 2.0, 10.0]       # Основний діапазон
	]
	
	var rand = randf()
	var cumulative_prob = 0.0

	for outcome in outcomes:
		cumulative_prob += outcome[0]
		if rand < cumulative_prob:
			if outcome[1] == outcome[2]:
				return outcome[1]
			else:
				return randf_range(outcome[1], outcome[2])

	return randf_range(2.0, 10.0)

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
