extends GridObject

@export var highlight_color: Color = Color.YELLOW
@export var shake_intensity: float = 0.1
@export var lift_height: float = 0.1
@export var lift_speed: float = 0.2

var original_material: Material
var original_position: Vector3
var is_hovered: bool = false

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	super._ready()
	original_position = position
	if mesh_instance_3d:
		original_material = mesh_instance_3d.material_override

func on_click(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		queue_free()
		print("Об'єкт видалено!")
		

func on_mouse_entered() -> void:
	mesh_instance_3d.material_override = StandardMaterial3D.new()
	mesh_instance_3d.material_override.albedo_color = highlight_color
	
	var target_position = original_position + Vector3(0, lift_height, 0)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, lift_speed).set_trans(Tween.TRANS_QUAD)
	

func on_mouse_exited() -> void:
	is_hovered = false
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, lift_speed).set_trans(Tween.TRANS_QUAD)
	mesh_instance_3d.material_override = original_material

func _process(delta):
	if is_hovered:
		pass
