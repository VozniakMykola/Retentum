class_name Tile
extends GridObject

signal tile_hovered(tile: Tile)
signal tile_unhovered(tile: Tile)
signal tile_clicked(tile: Tile, mouse_button: int)

@export var tile_data: TileResource:
	set(value):
		if tile_data == value:
			return
		tile_data = value
		if is_inside_tree():
			_apply_tile_settings()

#Settings
var tile_size: Vector3 = Vector3(1.0, 0.2, 1.0)
var hitbox_size: Vector3
var hitbox_y_offset: float

#Functionality
var current_tile_type: G.TileType = G.TileType.NORMAL:
	set(value):
		current_tile_type = value
		#match current_tile_type:
			#G.TileType.NORMAL:
				#pass
			#G.TileType.CHALKED:
				#pass
			#G.TileType.ENDGAME:
				#pass
			#G.TileType.DEAD:
				#pass
			#_:
				#pass
var current_tile_state: G.TileState = G.TileState.EMPTY:
	set(value):
		current_tile_state = value
		#match current_tile_state:
			#G.TileState.EMPTY:
				#pass
			#G.TileState.OCCUPIED:
				#pass
			#_:
				#pass

var tile_config := {
	G.TileState.EMPTY: {
		G.TileType.NORMAL: {
			"click": _on_click_normal,
			"on_mouse_enter": _on_mouse_entered_normal,
			"on_mouse_exit": _on_mouse_exited_normal,
			#"on_hover": 
		},
		G.TileType.CHALKED: {
			"click": _on_click_chalked,
			"on_mouse_enter": _on_mouse_entered_normal,
			"on_mouse_exit": _on_mouse_exited_normal,
			#"on_hover": _tile_hover_chalked
		},
		G.TileType.ENDGAME: {
			"click": _on_click_blocked,
			"on_mouse_enter": _on_mouse_entered_normal,
			"on_mouse_exit": _on_mouse_exited_normal,
			#"on_hover": _tile_hover_blocked
		},
		G.TileType.DEAD: {
			"click": func(): pass,
			"on_mouse_enter": func(): pass,
			"on_mouse_exit": func(): pass,
			"on_hover": func(): pass,
		}
	},
	G.TileState.OCCUPIED: {
		"_default": {
			"click": _on_click_blocked,
			#"hover": _tile_hover_blocked
		}
	}
}

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var area: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

const LIFT_OVERSHOOT: float = 0.25
const DROP_OVERSHOOT: float = 0.05
const BOUNCE_DURATION: float = 0.2
const LIFT_HEIGHT: float = 0.4
const LIFT_SPEED: float = 0.2

const TICK_TACK_SPEED: float = 0.25
#var hover_height: float = 0.5  # Висота коливання
#var hover_speed: float = 1  # Швидкість коливання


var original_mesh_position: Vector3
var lifted_mesh_position: Vector3
var is_hovered: bool = false
var current_tween: Tween


#region Setup
func _ready() -> void:
	hitbox_size = Vector3(tile_size.x, tile_size.y, tile_size.z)
	hitbox_y_offset = LIFT_HEIGHT
	
	original_mesh_position = mesh_instance.position
	lifted_mesh_position = original_mesh_position + Vector3(0, LIFT_HEIGHT, 0)
	
	if tile_data:
		_apply_tile_settings()
	if mesh_instance:
		var random_rotation = randi() % 4 * 90
		mesh_instance.rotation_degrees.y = random_rotation
		#mesh_instance.rotation.y = randf() * TAU  # TAU = 2*PI
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)

func _apply_tile_settings() -> void:
	if !tile_data:
		return
	if mesh_instance.material_override != tile_data.get_material():
		mesh_instance.material_override = tile_data.get_material()
	if mesh_instance:
		mesh_instance.mesh.size = tile_size
		mesh_instance.material_override = tile_data.get_material()
	if collision_shape:
		collision_shape.shape.size = hitbox_size
		collision_shape.position.y = hitbox_y_offset
#endregion

#region Interractions BASE
func _on_mouse_entered() -> void:
	tile_hovered.emit(self)
	is_hovered = true
	var action = _get_current_actions().get("on_mouse_enter")
	if action and action.is_valid():
		action.call()
	
func _on_mouse_exited() -> void:
	tile_unhovered.emit(self)
	is_hovered = false
	var action = _get_current_actions().get("on_mouse_exit")
	if action and action.is_valid():
		action.call()
	
func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	tile_clicked.emit(self, event.button_index)
	if event.button_index == MOUSE_BUTTON_LEFT:
		var click_action = _get_current_actions().get("click")
		if click_action and click_action.is_valid():
			click_action.call()

func _get_current_actions() -> Dictionary:
	var config = tile_config.get(current_tile_state, {})
	return config.get(
		current_tile_type if current_tile_state != G.TileState.OCCUPIED else "_default", 
		{}
	)
#endregion

#region Interractions HOVER

func _on_mouse_entered_normal():
	new_tween()
	
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(
		mesh_instance, 
		"position", 
		lifted_mesh_position + Vector3(0, LIFT_OVERSHOOT, 0), 
		LIFT_SPEED
	)
	#
	#current_tween.tween_property(
		#mesh_instance, 
		#"position", 
		#lifted_mesh_position, 
		#BOUNCE_DURATION
	#)
	current_tween.tween_callback(_start_hover_animation)
	
func _on_mouse_exited_normal():
	new_tween()
	
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(
		mesh_instance, 
		"position", 
		original_mesh_position - Vector3(0, DROP_OVERSHOOT, 0), 
		LIFT_SPEED
	)
	
	current_tween.tween_property(
		mesh_instance, 
		"position", 
		original_mesh_position, 
		BOUNCE_DURATION
	)

func _start_hover_animation():
	new_tween()
	
	current_tween.set_loops()
	current_tween.set_trans(Tween.TRANS_EXPO)
	current_tween.set_ease(Tween.EASE_OUT)
	
	# Рух вниз
	current_tween.tween_property(
		mesh_instance, 
		"position:y", 
		lifted_mesh_position.y, 
		TICK_TACK_SPEED
	)
	
	current_tween.tween_property(
		mesh_instance, 
		"position:y", 
		lifted_mesh_position.y + LIFT_OVERSHOOT, 
		TICK_TACK_SPEED
	)
	
	current_tween.tween_callback(_start_hover_animation)
#endregion

#region Interaction CLICK
func _on_click_normal():
	set_tile_type(G.TileType.DEAD)
	collapse()
	pass

func _on_click_chalked():
	#clear chalk
	pass

func _on_click_blocked():
	#shaking
	pass
#endregion

#region Auxiliary
func new_tween() -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()
	current_tween = create_tween()

func collapse() -> void:
	pass

#endregion

#region States logic

func set_tile_type(new_type: G.TileType):
	call_deferred("_set_tile_type_deferred", new_type)

func _set_tile_type_deferred(new_type: G.TileType):
	current_tile_type = new_type

func set_tile_state(new_state: G.TileState):
	call_deferred("_set_tile_state_deferred", new_state)

func _set_tile_state_deferred(new_state: G.TileState):
	current_tile_state = new_state
#endregion
