class_name TileResource
extends Resource

@export var tile_id: String
@export_group("Visual")
@export var material: StandardMaterial3D
@export var albedo_color: Color = Color.WHITE
@export var ignore_albedo: bool = false
@export_group("Journal")
@export var is_unlocked: bool = false
