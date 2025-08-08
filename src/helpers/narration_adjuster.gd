class_name NarrationAdjuster
extends Resource

@export var biome: G.BiomeType
@export var chalk_tiles_rate: float
@export var chalk_inventory_count: int

const CHALK_RATES: Array = [
	{ "range": Vector2(0, 0),   "weight": 1.0/50 },    # 2%
	{ "range": Vector2(90, 100), "weight": 1.0/100 },  # 1%
	{ "range": Vector2(10, 35),  "weight": 1.0 }       # (97%)
]

const CHALK_COUNTS: Array = [
	{ "range": Vector2(0, 2),   "weight": 1.0/50 },  # 2%
	{ "range": Vector2(15, 25), "weight": 1.0/110 }, # 0.9%
	{ "range": Vector2(10, 15), "weight": 1.0/25 },  # 4%
	{ "range": Vector2(6, 10), "weight": 1.0/5 },    # 20%
	{ "range": Vector2(3, 6),  "weight": 1.0 }       # (73%)
]

static func get_data() -> NarrationAdjuster:
	var config = NarrationAdjuster.new()
	
	config.biome = _select_biome()
	
	config.chalk_tiles_rate = _set_rate(CHALK_RATES)
	config.chalk_inventory_count = _set_rate(CHALK_COUNTS)
	return config

static func _set_rate(rates: Array) -> float:
	var total_weight: float = 0.0
	for rate in rates:
		total_weight += rate["weight"]
	
	var random_selection = randf() * total_weight
	var cumulative_weight: float = 0.0

	for rate in rates:
		cumulative_weight += rate["weight"]
		if random_selection <= cumulative_weight:
			return randf_range(rate["range"].x, rate["range"].y)
	
	var last_range = rates.back()["range"]
	return randf_range(last_range.x, last_range.y)

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
