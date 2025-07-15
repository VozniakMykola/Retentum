class_name TileResource
extends Resource

@export var tile_id: String
@export_group("Visual")
@export var base_material: StandardMaterial3D
@export var albedo_color: G.ColorType = G.ColorType.WHITE
@export var ignore_albedo: bool = false
@export_group("Journal")
@export var is_unlocked: bool = false

func get_material() -> StandardMaterial3D:
	if !base_material:
		return load("res://src/tiles/list/test.tres") as StandardMaterial3D
	if ignore_albedo:
		return base_material
	var mat = base_material
	mat.albedo_color = G.get_color(albedo_color)
	return mat
