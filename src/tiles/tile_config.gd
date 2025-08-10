class_name TileConfig
extends Resource

@export var tile_res: TileResource = preload("res://src/tiles/list/gray_concrete.tres") as TileResource
@export var tile_state: G.TileState = G.TileState.EMPTY
@export var tile_type: G.TileType = G.TileType.NULL
@export var chalk_type = null
@export var guidance_vec: Vector2i = Direction2D.UP
