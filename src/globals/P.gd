extends Node

@export_category("Game stat")
@export var total_games: int = 0
@export var total_wins: int = 0
@export var total_losses: int = 0
@export var current_win_streak: int = 0
@export var current_loss_streak: int = 0
@export_category("Sequences stat")
@export var sequences_completed: int = 0
@export var current_sequence_index: int = 0
@export var climaxes_completed: int = 0
@export var middles_completed: int = 0
@export_category("Unlocked elements")
@export var unlocked_chalks: Array[G.ChalkType] = []
@export var unlocked_biomes: Array[G.BiomeType] =  [G.BiomeType.PLAZA]
@export var last_unlocked_biome: Variant = null
@export var last_unlocked_chalk: Variant = null
@export var is_last_unlocked_biome_played: bool = false

enum PacingState {
	EASY, 
	MEDIUM, 
	HARD, 
	CLIMAX 
	}

const PACING_SEQUENCE = [
	PacingState.MEDIUM, #CLIFFHANGER
	PacingState.EASY,
	PacingState.MEDIUM, #SMALL REWARD
	PacingState.HARD,
	PacingState.MEDIUM,
	PacingState.HARD,
	PacingState.CLIMAX,
	PacingState.EASY, #FINAL REWARD
	PacingState.EASY #LULL
]

const AFTER_CLIMAX_INDEX = 7
const AFTER_MIDDLE_INDEX = 2

const BIOME_REQUIREMENTS = {
	G.BiomeType.RESTROOM: 1, 
	G.BiomeType.PAITITI_MEADOW: 2, 
	G.BiomeType.PADDED_CELL: 3, 
	G.BiomeType.FLUFFY_PRISON: 4,
	G.BiomeType.OFFICE: 5,
	G.BiomeType.RESILIENCE_MEADOW: 6, 
	G.BiomeType.FACTORY: 7,
	G.BiomeType.SPACEYARD: 25
}

const CHALK_REQUIREMENTS = {
	G.ChalkType.SCRIBBLE: 1, 
	G.ChalkType.DECOY: 2, 
	G.ChalkType.REVELATION: 2, 
	G.ChalkType.GUIDANCE: 3, 
	G.ChalkType.HOPSCOTCH: 4,
	G.ChalkType.SCOTOMA: 4, 
	G.ChalkType.SIGIL: 5, 
}
#G.ChalkType.SUPERPOSITION: 4, 
#G.ChalkType.ITINERARIUM: 5

func get_current_pacing_state() -> PacingState:
	return PACING_SEQUENCE[current_sequence_index]

func record_session_result(is_win: bool) -> Array[String]:
	last_unlocked_chalk = null #a new chalk is shown for one game and then a random ones
	_update_game_stat(is_win)
	var unlocks: Array[String] = []
	current_sequence_index = (current_sequence_index + 1) % PACING_SEQUENCE.size()
	
	match current_sequence_index:
		0: sequences_completed += 1
		AFTER_MIDDLE_INDEX:
			middles_completed += 1
			unlocks.append_array(_check_chalk_unlocks())
		AFTER_CLIMAX_INDEX: 
			climaxes_completed += 1
			unlocks.append_array(_check_biome_unlocks())
	
	return unlocks

func _update_game_stat(is_win: bool) -> void:
	total_games += 1
	if is_win:
		total_wins += 1
		current_win_streak += 1
		current_loss_streak = 0
	else:
		total_losses += 1
		current_loss_streak += 1
		current_win_streak = 0

func _check_biome_unlocks() -> Array[String]:
	var new_unlocks: Array[String] = []
	for biome in BIOME_REQUIREMENTS:
		var required_climaxes = BIOME_REQUIREMENTS[biome]
		if biome not in unlocked_biomes and climaxes_completed >= required_climaxes:
			unlocked_biomes.append(biome)
			last_unlocked_biome = biome
			new_unlocks.append(G.BiomeType.keys()[biome])
	return new_unlocks

func _check_chalk_unlocks() -> Array[String]:
	var new_unlocks: Array[String] = []
	last_unlocked_biome = null #a new biome is shown for half of the pacing sequence and then a random one
	
	for chalk_type in CHALK_REQUIREMENTS:
		var required_middles = CHALK_REQUIREMENTS[chalk_type]
		if chalk_type not in unlocked_chalks and middles_completed >= required_middles:
			unlocked_chalks.append(chalk_type)
			last_unlocked_chalk = chalk_type
			new_unlocks.append(G.ChalkType.keys()[chalk_type])
	
	return new_unlocks
