extends Node

func session_ended(is_win: bool, total_seconds: int):
	total_games += 1
	if is_win:
		total_wins += 1
		current_win_streak += 1
		current_loss_streak = 0
		#unlock_new_biome_ after some total_wins count!
		#change biome only after win!!!
	else:
		total_losses += 1
		current_loss_streak += 1
		current_win_streak = 0
	#some pacing manipulation -
	#pacing adjustments depending on how the gaming experience looks, 
	#as well as default pacing depending on the number of games
	
	#New worlds unlock by default after some total_games count
#[!Tip] all unlocked biomes and worlds are shown in random order after unlocking
#ПІСЛЯ КОЖНОЇ ГРИ ДЕФАЙНИТИ ПАРАМЕТРИ НАСТУПНОЇ ГРИ!!!

var total_games: int = 0
var total_wins: int = 0
var total_losses: int = 0
var current_win_streak: int = 0
var current_loss_streak: int = 0 

enum PacingState {
	REGULAR,
	EASY,
	DIFFICULT,
}

enum MoodPolarity {
	VERY_POSITIVE,
	POSITIVE,
	NEUTRAL,
	NEGATIVE,
	VERY_NEGATIVE
}
#polarity for chalks, worlds,
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

enum ColorType {
	GRAY_CONCRETE, 
	WHITE_TILE, 
	BLACK_TILE, 
	GREEN_CHIA, 
	NAVY_LAPIS, 
	BROWN_RUST,  
	ORANGE_BUFFER,  
	PINK_FUR,   
	RED_FUR,   
	# Secondary colors (Office)
	BLUE_CARPET,
	CYAN_CARPET,
	PURPLE_CARPET,
	TEAL_CARPET,
	YELLOW_CARPET,
	OLIVE_CARPET,
	DARK_GRAY_CARPET
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
#enum GameMode{
	#CLASSIC,
	#TUTORIAL,
	#ISLANDS,
	#EXPLORE
#}
#endregion

# Game state properties need to jsonize

#if failed_level_conut > completed_level_conut *2 then show tips

var total_chalk_issued: int = 0 #gived by game #divide by random and specified?
var total_chalk_collected: int = 0 #collected by player #divide by random and specified?
var total_chalk_spawned: int = 0 #spawned by game
var total_chalk_used: int = 0 #spawned by player

#var unlocked_tiles: Array[ColorType]
#unlocked other staff for bestiary
#unlock_tile func?
