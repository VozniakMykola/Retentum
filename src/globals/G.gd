extends Node

const Y_RATIO : int = 2 #y/x
const X_RATIO : float = 0.5 #x/y

const POST_PROCESSING = preload("res://scenes/other/post_processing.tscn")

func _ready():
	var eff = POST_PROCESSING.instantiate()
	add_child(eff)

signal turn_next(turn: GameTurn)
var current_turn: GameTurn = GameTurn.NONE_TURN
enum GameTurn {
	PLAYER_TURN,
	MONKE_TURN,
	NONE_TURN,
}
func set_turn(turn: GameTurn):
	current_turn = turn
	emit_signal("turn_next", current_turn)

enum ChalkType {  
	SCRIBBLE,
	DECOY, 
	HOPSCOTCH, 
	SCOTOMA, 
	REVELATION, 
	SIGIL, 
	GUIDANCE, 
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

var chalk_textures: Dictionary = CHALK_RESOURCES_CH

const CHALK_RESOURCES = {
	ChalkType.SCRIBBLE: preload("res://assets/chalks/scribble.png"), 
	ChalkType.DECOY: preload("res://assets/chalks/decoy.png"), 
	ChalkType.HOPSCOTCH: preload("res://assets/chalks/hopscotch.png"), 
	ChalkType.SCOTOMA: preload("res://assets/chalks/scotoma.png"), 
	ChalkType.REVELATION: preload("res://assets/chalks/revelation.png"), 
	ChalkType.SIGIL: preload("res://assets/chalks/sigil.png"), 
	ChalkType.GUIDANCE: preload("res://assets/chalks/guidance.png"),
}

const CHALK_RESOURCES_CH = {
	ChalkType.SCRIBBLE: preload("res://assets/chalks/scribble_ch.png"), 
	ChalkType.DECOY: preload("res://assets/chalks/decoy_ch.png"), 
	ChalkType.HOPSCOTCH: preload("res://assets/chalks/hopscotch_ch.png"), 
	ChalkType.SCOTOMA: preload("res://assets/chalks/scotoma_ch.png"), 
	ChalkType.REVELATION: preload("res://assets/chalks/revelation_ch.png"), 
	ChalkType.SIGIL: preload("res://assets/chalks/sigil_ch.png"), 
	ChalkType.GUIDANCE: preload("res://assets/chalks/guidance_ch.png"),
}

enum ShapePattern { RECTANGLE, DIAMOND, CIRCLE, CROSS, ISLAND }

enum GenCellType {
	VOID = 0,
	EDGE = 1,
	SHORE = 2,
	LAND = 3,
	CENTER = 4
}

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
	SQUARES
	}

enum TileType { NORMAL, DEAD, CHALKED, ENDGAME, NULL }
enum TileState { EMPTY, OCCUPIED }

enum ColorType {
	BLACK, BLUE, BROWN, CYAN, DARK_GRAY, GRAY, GREEN, NAVY, OLIVE, 
	ORANGE, PINK, PURPLE, RED, TEAL, WHITE, YELLOW
}

var active_color_module: Dictionary = COLOR_MODULE_1
const COLOR_MODULE_1 = {
	ColorType.GRAY: Color("#7F8C8D"),
	ColorType.WHITE: Color("#ECF0F1"),
	ColorType.BLACK: Color("#2C3E50"),
	ColorType.GREEN: Color("#569331"),
	ColorType.NAVY: Color("#546DFF"), #1A5276
	ColorType.BROWN: Color("#b76433"),
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
