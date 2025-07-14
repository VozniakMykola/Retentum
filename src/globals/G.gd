extends Node

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
	
enum BiomeType {
	PLAZA,
	RESTROOM,
	CHIA_LAWN_PAITITI,
	PADDED_CELL,
	FLUFFY_PRISON,
	OFFICE,
	CHIA_LAWN_RESILIENCE,
	FACTORY,
	SPACEYARD
}

const BIOME_RESOURCES = {
	BiomeType.PLAZA: preload("res://src/biomes/list/plaza.tres"),
	BiomeType.RESTROOM: preload("res://src/biomes/list/restroom.tres"),
	BiomeType.CHIA_LAWN_PAITITI: preload("res://src/biomes/list/chia_lawn_paititi.tres"),
	BiomeType.PADDED_CELL: preload("res://src/biomes/list/padded_cell.tres"),
	BiomeType.FLUFFY_PRISON: preload("res://src/biomes/list/fluffy_prison.tres"),
	BiomeType.OFFICE: preload("res://src/biomes/list/office.tres"),
	BiomeType.CHIA_LAWN_RESILIENCE: preload("res://src/biomes/list/chia_lawn_resilience.tres"),
	BiomeType.FACTORY: preload("res://src/biomes/list/factory.tres"),
	BiomeType.SPACEYARD: preload("res://src/biomes/list/spaceyard.tres")
}

const CHALK_RESOURCES = {
	
}

enum ShapePattern { RECTANGLE, DIAMOND, CIRCLE, CROSS, ISLAND }
enum TerrainPattern { 
	SOLID, 
	CHECKERED, 
	DOTTED, 
	HEARTS, 
	PLAID, 
	PATCHY, 
	NOISE,
	ZEBRA_V,
	ZEBRA_H,
	ARCHIPELAGO,
	BIG_HEART,
	}
enum TileState { NORMAL, DEAD, CHALKED, ENDGAME }
enum GameplayState { EMPTY, OCCUPIED }

enum ColorType {
	BLACK, BLUE, BROWN, CYAN, DARK_GRAY, GRAY, GREEN, NAVY, OLIVE, 
	ORANGE, PINK, PURPLE, RED, TEAL, WHITE, YELLOW
}

var active_color_module: Dictionary = COLOR_MODULE_1
const COLOR_MODULE_1 = {
	ColorType.GRAY: Color("#7F8C8D"),
	ColorType.WHITE: Color("#ECF0F1"),
	ColorType.BLACK: Color("#2C3E50"),
	ColorType.GREEN: Color("#27AE60"),
	ColorType.NAVY: Color("#1A5276"),
	ColorType.BROWN: Color("#A84300"),
	ColorType.OLIVE: Color("#8D6E63"),
	ColorType.ORANGE: Color("#E67E22"),
	ColorType.PINK: Color("#F8A5C2"),
	ColorType.RED: Color("#E74C3C"),
	ColorType.BLUE: Color("#3498DB"),
	ColorType.CYAN: Color("#00CEC9"),
	ColorType.PURPLE: Color("#9B59B6"),
	ColorType.TEAL: Color("#1ABC9C"),
	ColorType.YELLOW: Color("#F1C40F"),
	ColorType.DARK_GRAY: Color("#5D6D7E")
}

func get_color(color_enum: ColorType) -> Color:
	return active_color_module.get(color_enum, Color.WHITE)
