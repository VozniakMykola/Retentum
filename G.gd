extends Node

#region Pacing & Progression
#Total data
var total_games: int = 0
var total_wins: int = 0
var total_losses: int = 0
var current_win_streak: int = 0
var current_loss_streak: int = 0
#Pacing data
var sequences_completed: int = 0
var current_sequence_index: int = 0 
var climaxes_completed: int = 0
var middles_completed: int = 0
var current_pacing_state: PacingState = PacingState.MEDIUM

enum PacingState{
	EASY,
	MEDIUM,
	HARD,
	CLIMAX,
}

var pacing_sequence = [
	PacingState.MEDIUM, #CLIFFHANGER
	PacingState.EASY,
	PacingState.MEDIUM, #REWARD
	PacingState.HARD,
	PacingState.MEDIUM,
	PacingState.HARD,
	PacingState.CLIMAX,
	PacingState.EASY, #REWARD
	PacingState.EASY #LULL
]

func session_ended(is_win: bool, total_seconds: int):
	#Total data
	total_games += 1
	if is_win:
		total_wins += 1
		current_win_streak += 1
		current_loss_streak = 0
	else:
		total_losses += 1
		current_loss_streak += 1
		current_win_streak = 0
	#Pacing data
	current_sequence_index = (current_sequence_index + 1) % pacing_sequence.size()
	match current_sequence_index:
		0:
			sequences_completed += 1
		7:
			climaxes_completed += 1
		2:
			middles_completed += 1
		
	current_pacing_state = pacing_sequence[current_sequence_index]
#endregion

#region Colors
enum ColorType {
	BLACK,
	BLUE,
	BROWN,
	CYAN,
	DARK_GRAY,
	GRAY,
	GREEN,
	NAVY,
	OLIVE,
	ORANGE,
	PINK,
	PURPLE,
	RED,
	TEAL,
	WHITE,
	YELLOW
}

var active_color_module: Dictionary = COLOR_MODULE_1
const COLOR_MODULE_1 = {
	G.ColorType.GRAY: Color("#7F8C8D"),
	G.ColorType.WHITE: Color("#ECF0F1"),
	G.ColorType.BLACK: Color("#2C3E50"),
	G.ColorType.GREEN: Color("#27AE60"),
	G.ColorType.NAVY: Color("#1A5276"),
	G.ColorType.BROWN: Color("#A84300"),
	G.ColorType.OLIVE: Color("#8D6E63"),
	G.ColorType.ORANGE: Color("#E67E22"),
	G.ColorType.PINK: Color("#F8A5C2"),
	G.ColorType.RED: Color("#E74C3C"),
	G.ColorType.BLUE: Color("#3498DB"),
	G.ColorType.CYAN: Color("#00CEC9"),
	G.ColorType.PURPLE: Color("#9B59B6"),
	G.ColorType.TEAL: Color("#1ABC9C"),
	G.ColorType.YELLOW: Color("#F1C40F"),
	G.ColorType.DARK_GRAY: Color("#5D6D7E")
}

func get_color(color_enum: ColorType) -> Color:
	return active_color_module.get(color_enum, Color.WHITE)
#endregion

##region Materials
#enum MaterialType {
	#CONCRETE, 
	#TILE, 
	#CHIA, 
	#LAPIS, 
	#RUST,  
	#BUFFER,  
	#FUR,     
	#CARPET,
	#TEST
#}
##endregion


#region Enums new

enum ShapePattern {
	RECTANGLE,
	DIAMOND,
	#ETC ETC....
}

enum TerrainPattern {
	SOLID,
	CHECKERED,
	DOTTED,
	HEARTS,
	PLAID,
	PATCHY,
	NOISE,
	#ETC ETC....
}
#endregion
#region Enums


enum BiomeType {
	PLAZA,
	RESTROOM,
	CHIA_LAWN_PAITITI,
	CHIA_LAWN_RESILIENCE,
	PADDED_CELL,
	FLUFFY_PRISON,
	OFFICE,
	FACTORY,
	SPACEYARD
}

enum ChalkType {
	DECOY,
	HOPSCOTCH,
	SCOTOMA,
	REVELATION,
	SIGIL,
	GUIDANCE,
	ITINERARIUM,
	SUPERPOSITION
}

enum TileState{
	NORMAL,
	DEAD,
	CHALKED,
	ENDGAME
}

enum GameplayState {
	EMPTY,
	OCCUPIED
}

#endregion
#if failed_level_conut > completed_level_conut *2 then show tips

var total_chalk_issued: int = 0 #gived by game #divide by random and specified?
var total_chalk_collected: int = 0 #collected by player #divide by random and specified?
var total_chalk_spawned: int = 0 #spawned by game
var total_chalk_used: int = 0 #spawned by player

#var unlocked_tiles: Array[ColorType]
#unlocked other staff for bestiary
#unlock_tile func?
