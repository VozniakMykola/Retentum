class_name Tile
extends GridObject

signal mouse_entered
signal mouse_exited
signal clicked(event: InputEventMouseButton)

@export_group("Functionality")
@export var fwe7m8knrj_biome_unlock: String
@export var fwe7m8knrj_name_id: String
@export_group("Visual")
@export var fwe7m8knrj_material: float = 0.3
@export var tile_size: Vector3 = Vector3(1.0, 0.5, 1.0)
@export var hitbox_size: Vector3 = Vector3(1.0, 0.25, 1.0)
@export var hitbox_offset: Vector3 = Vector3(0, -0.25, 0)
@export_group("Positive Interractions")
@export var lift_height: float = 0.3
@export var lift_speed: float = 0.2
@export var glow_intensity: float = 0.5
@export_group("Negative Interractions")
@export var shake_intensity: float = 0.1

var original_position: Vector3
var is_hovered: bool = false
var default_material: Material

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
var area: Area3D
var collision_shape: CollisionShape3D

func _ready() -> void:
	super._ready()
	original_position = position
	
	# Mesh settings
	if mesh_instance:
		default_material = mesh_instance.get_surface_override_material(0)
		var random_rotation = randi() % 4 * 90
		mesh_instance.rotation_degrees.y = random_rotation
		mesh_instance.scale = tile_size
	_setup_area()

func _setup_area() -> void:
	area = Area3D.new()
	collision_shape = CollisionShape3D.new()
	
	var box_shape = BoxShape3D.new()
	box_shape.size = hitbox_size
	collision_shape.shape = box_shape
	collision_shape.position += hitbox_offset
	area.add_child(collision_shape)
	add_child(area)
	
	area.mouse_entered.connect(_on_area_mouse_entered)
	area.mouse_exited.connect(_on_area_mouse_exited)
	area.input_event.connect(_on_area_input_event)

func _process(delta):
	if is_hovered:
		pass

#region Interractions

func _on_area_mouse_entered() -> void:
	mouse_entered.emit()
	on_mouse_entered()

func _on_area_mouse_exited() -> void:
	mouse_exited.emit()
	on_mouse_exited()

func _on_area_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked.emit(event)
		on_click(event)
		
func on_mouse_entered() -> void:
	is_hovered = true
	var target_position = original_position + Vector3(0, lift_height, 0)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, lift_speed).set_trans(Tween.TRANS_QUAD)
	_apply_glow_effect(true)

func on_mouse_exited() -> void:
	is_hovered = false
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, lift_speed).set_trans(Tween.TRANS_QUAD)
	_apply_glow_effect(false)

func on_click(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		queue_free()
		print("Об'єкт видалено!")
		#change to anim and barnch

func _apply_glow_effect(enable: bool) -> void:
	if mesh_instance and default_material:
		if enable:
			var glow_material = default_material.duplicate()
			glow_material.emission_enabled = true
			glow_material.emission = Color(1, 1, 1) * glow_intensity
			mesh_instance.set_surface_override_material(0, glow_material)
		else:
			mesh_instance.set_surface_override_material(0, default_material)
#endregion
