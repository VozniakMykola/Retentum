class_name TileConfig
extends Resource

@export var tile_res: TileResource
@export var tile_state: G.TileState = G.TileState.EMPTY
@export var tile_type: G.TileType = G.TileType.DEAD
@export var chalk_type = null
@export var guidance_vec: Vector2i = Vector2i.UP
