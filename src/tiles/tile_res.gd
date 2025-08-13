class_name TileResource
extends Resource

@export var tile_id: String
@export_group("Visual")
@export var base_material: StandardMaterial3D
@export var albedo_color: G.ColorType = G.ColorType.WHITE
@export var ignore_albedo: bool = false
@export var is_rotatable: bool = true
#@export_group("Journal")
#@export var is_unlocked: bool = false

func get_material() -> StandardMaterial3D:
	if !base_material:
		return load("res://assets/materials/unused/test.tres").duplicate() as StandardMaterial3D
	if ignore_albedo:
		return base_material.duplicate()
	var mat = base_material.duplicate()
	mat.albedo_color = G.get_color(albedo_color)
	return mat

func _are_materials_same(mat_b: StandardMaterial3D) -> bool:
	if !base_material || !mat_b:
		return false
	if !ignore_albedo:
		return (
			mat_b.albedo_texture == base_material.albedo_texture
			and mat_b.albedo_color == G.get_color(albedo_color)
			)
	else:
		return (
			mat_b.albedo_texture == base_material.albedo_texture
			and mat_b.albedo_color == base_material.albedo_color
			)
