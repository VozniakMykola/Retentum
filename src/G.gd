extends Node

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
enum GameMode{
	CLASSIC,
	TUTORIAL,
	ISLANDS,
	EXPLORE
}
#endregion

const TILE_SIZE: float = 1

# Game state properties need to jsonize
var completed_level_conut: int = 0
var failed_level_conut: int = 0
#if failed_level_conut > completed_level_conut *2 then show tips

var total_chalk_issued: int = 0 #gived by game #divide by random and specified?
var total_chalk_collected: int = 0 #collected by player #divide by random and specified?
var total_chalk_spawned: int = 0 #spawned by game
var total_chalk_used: int = 0 #spawned by player

var unlocked_tiles: Array[ColorType]
#unlocked other staff for bestiary
#unlock_tile func?
