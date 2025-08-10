class_name Tile
extends GridObject

#Onready
@onready var area: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var sprite: Node3D = $Sprite
@onready var mesh: MeshInstance3D = $Sprite/Mesh
@onready var chalk: Sprite3D = $Sprite/Chalk
@onready var endgame: Node3D = $Sprite/Endgame

#Export
@export var tile_config: TileConfig:
	set(value):
		if value == null:
			return
		tile_config = value
		if is_tile_core_allow_recording:
			tile_core = tile_config

var tile_core: TileConfig = TileConfig.new():
	set(new_tile_core):
		if is_inside_tree():
			var old_tile_core: TileConfig = tile_core
			tile_core = new_tile_core
			set_tile_type(new_tile_core.tile_type, old_tile_core.tile_type)


#region Tile Type FSM
var tile_behavior: Dictionary = {
	G.TileState.EMPTY: {
		G.TileType.NORMAL: {
			"click": set_tile_type.bind(G.TileType.DEAD, G.TileType.NORMAL, true),
			"on_mouse_enter": anim_tile_up,
			"on_mouse_exit": anim_tile_down,
			#"on_hover": 
			#cat_on_it
		},
		G.TileType.CHALKED: {
			"click": set_tile_type.bind(G.TileType.NORMAL, G.TileType.CHALKED, true),
			"on_mouse_enter": anim_tile_up,
			"on_mouse_exit": anim_tile_down,
			#"on_hover": _tile_hover_chalked
			#cat_on_it
		},
		G.TileType.ENDGAME: {
			"click": func(): pass,
			"on_mouse_enter": func(): pass,
			"on_mouse_exit": func(): pass,
			#"on_hover": _tile_hover_blocked
			#cat_on_it
		},
		G.TileType.DEAD: {
			"click": func(): pass,
			"on_mouse_enter": func(): pass,
			"on_mouse_exit": func(): pass,
			"on_hover": func(): pass,
			#cat_on_it
		},
		G.TileType.NULL: { #NULL
			"click": func(): pass, #NULL
			"on_mouse_enter": func(): pass, #NULL
			"on_mouse_exit": func(): pass, #NULL
			"on_hover": func(): pass, #NULL
		}
	},
	G.TileState.OCCUPIED: {
		"_default": {
			"click": func(): pass,
			#"hover": _tile_hover_blocked
		}
	}
}

const DIR_ROTATIONS: Dictionary = {
	Direction2D.UP: Vector3(-90.0, 45.0, 0.0),
	Direction2D.DOWN: Vector3(90.0, 45.0, 0.0),
	Direction2D.LEFT: Vector3(90.0, -45.0, 0.0),
	Direction2D.RIGHT: Vector3(-90.0, -45.0, 0.0),
	Direction2D.UP_LEFT: Vector3(90.0, -90.0, 0.0),
	Direction2D.UP_RIGHT: Vector3(-90.0, 0.0, 0.0),
	Direction2D.DOWN_LEFT: Vector3(90.0, 0.0, 0.0),
	Direction2D.DOWN_RIGHT: Vector3(-90.0, -90.0, 0.0)
}
#endregion

#region Anim
#region Anim Consts
#anim_fall
const ROTATION_RATE: float = 0.5
const ROTATION_SPEED: float = 1
const FALL_DURATION: float = 0.45
const FALL_DISTANCE: float = 5.0
#anim_tile_down #anim_tile_up
const LIFT_HEIGHT: float = 0.4
const LIFT_SPEED: float = 0.2
const LIFT_OVERSHOOT: float = 0.25
const DROP_OVERSHOOT: float = 0.05
const BOUNCE_DURATION: float = 0.2
#anim_floating
const TICK_TACK_SPEED: float = 0.25
#anim_appear_1
const APPEAR_SPEED_1: float = 0.2
#anim_appear_2
const APPEAR_SPEED: float = 0.2
const APPEAR_HEIGHT: float = 0.4
const APPEAR_OVERSHOOT: float = 0.2
#endregion
#region Anim Helpers
var original_sprite_position: Vector3
var original_sprite_rotation: Vector3
var lifted_sprite_position: Vector3
var is_hovered: bool = false
var current_tween: Tween
#endregion
#endregion

#MAY BE DELETED
const TILE_SIZE: Vector3 = Vector3(1.0, 0.2, 1.0)
var hitbox_size: Vector3 = Vector3(TILE_SIZE.x, TILE_SIZE.y + LIFT_HEIGHT, TILE_SIZE.z)
var hitbox_y_offset: float = LIFT_HEIGHT/2
#------------

var is_tile_core_allow_recording: bool = false

#region Setup
func _ready() -> void:
	G.turn_next.connect(_on_turn_next)
	#MAY BE DELETED
	original_sprite_position = sprite.position
	original_sprite_rotation = sprite.rotation
	lifted_sprite_position = original_sprite_position + Vector3(0, LIFT_HEIGHT, 0)
	_update_material()
	var random_flip_x: bool = (randi() % 2) == 0
	#mesh.mesh.size = TILE_SIZE
	mesh.rotation_degrees.x = 180 if random_flip_x else 0
	collision_shape.shape.size = hitbox_size
	collision_shape.position.y = hitbox_y_offset
	_apply_tile_type_NULL()
	#------------
	is_tile_core_allow_recording = true
	#------------


func _update_material() -> void:
	if  !tile_core.tile_res._are_materials_same(mesh.material_override):
		mesh.material_override = tile_core.tile_res.get_material()
		if tile_core.tile_res.is_rotatable:
			mesh.rotation_degrees.y = randi() % 4 * 90
		else:
			mesh.rotation_degrees.y = 0

#endregion

#region Interractions BASE
func _on_turn_next(turn: G.GameTurn) -> void:
	if turn == G.GameTurn.PLAYER_TURN and is_hovered:
		_on_mouse_entered()

func _on_mouse_entered() -> void:
	is_hovered = true
	var action = _get_current_actions().get("on_mouse_enter")
	if action and action.is_valid():
		action.call()
	
func _on_mouse_exited() -> void:
	is_hovered = false
	var action = _get_current_actions().get("on_mouse_exit")
	if action and action.is_valid():
		action.call()
	
func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		var click_action = _get_current_actions().get("click")
		if click_action and click_action.is_valid():
			click_action.call()

func _get_current_actions(tile_state: G.TileState = tile_core.tile_state) -> Dictionary:
	if G.current_turn == G.GameTurn.PLAYER_TURN:
		var config = tile_behavior.get(tile_state, {})
		return config.get(
			tile_core.tile_type if tile_state != G.TileState.OCCUPIED else "_default",
			{}
		)
		
	else:
		return tile_behavior.get(G.TileState.OCCUPIED, {}).get("_default", {})
#endregion

#region Animations
func new_tween() -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()
	current_tween = create_tween()

func anim_tile_up() -> void:
	new_tween()
	
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(
		sprite, 
		"position", 
		lifted_sprite_position + Vector3(0, LIFT_OVERSHOOT, 0), 
		LIFT_SPEED
	)
	
	#current_tween.tween_property(
		#sprite, 
		#"position", 
		#lifted_sprite_position, 
		#BOUNCE_DURATION
	#)
	current_tween.tween_callback(anim_floating)
	
func anim_tile_down() -> void:
	new_tween()
	
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(
		sprite, 
		"position", 
		original_sprite_position - Vector3(0, DROP_OVERSHOOT, 0), 
		LIFT_SPEED
	)
	
	current_tween.tween_property(
		sprite, 
		"position", 
		original_sprite_position, 
		BOUNCE_DURATION
	)

func anim_floating() -> void:
	new_tween()
	
	current_tween.set_loops()
	current_tween.set_trans(Tween.TRANS_EXPO)
	current_tween.set_ease(Tween.EASE_OUT)
	
	current_tween.tween_property(
		sprite, 
		"position:y", 
		lifted_sprite_position.y, 
		TICK_TACK_SPEED
	)
	
	current_tween.tween_interval(0.05)
	
	current_tween.tween_property(
		sprite, 
		"position:y", 
		lifted_sprite_position.y + LIFT_OVERSHOOT, 
		TICK_TACK_SPEED
	)
	
	current_tween.tween_interval(0.05)


func anim_fall() -> void:
	new_tween()
	current_tween.set_parallel(true)
	
	#falling
	current_tween.tween_property(sprite, "position:y", 
		sprite.position.y - FALL_DISTANCE, FALL_DURATION).set_trans(Tween.TRANS_LINEAR)
	
	#Euler's Disk effect
	var dir_x = 1 if randf() > 0.5 else -1
	var dir_y = 1 if randf() > 0.5 else -1
	var dir_z = 1 if randf() > 0.5 else -1
	current_tween.tween_property(sprite, "rotation", 
		Vector3(sprite.rotation.x + dir_x * ROTATION_RATE, 
				sprite.rotation.y + dir_y * ROTATION_RATE, 
				sprite.rotation.z + dir_z * ROTATION_RATE),
		randf_range(ROTATION_SPEED-0.5, ROTATION_SPEED+0.5)).set_trans(Tween.TRANS_LINEAR)
	
	#Disappearing
	current_tween.tween_property(mesh.material_override, "albedo_color:a", 0.0, FALL_DURATION*0.70).set_delay(FALL_DURATION*0.25)

	await current_tween.finished

func anim_appear_2() -> void:
	new_tween()
	
	current_tween.tween_property(sprite, "scale", Vector3.ONE, APPEAR_SPEED * 1.5)\
		.from(Vector3.ZERO)\
		.set_ease(Tween.EASE_OUT)

	current_tween.set_parallel(true)
	
	current_tween.tween_property(
		sprite, 
		"position:y", 
		original_sprite_position.y + APPEAR_HEIGHT, 
		APPEAR_SPEED * 0.5
	).from_current().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var tween_down = create_tween()
	tween_down.tween_property(
		sprite, 
		"position:y", 
		original_sprite_position.y - APPEAR_OVERSHOOT, 
		APPEAR_SPEED * 0.5
	).set_delay(APPEAR_SPEED * 0.5)
	tween_down.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tween_down.tween_property(
		sprite, 
		"position:y", 
		original_sprite_position.y, 
		APPEAR_SPEED * 0.5
	)
	
	await current_tween.finished

func anim_appear_1() -> void:
	new_tween()
	
	current_tween.tween_property(sprite, "scale", Vector3.ONE, APPEAR_SPEED_1)\
		.from(Vector3.ZERO)\
		.set_ease(Tween.EASE_OUT)

	await current_tween.finished

#endregion

#region States logic

func set_tile_type(new_type: G.TileType , old_type = tile_core.tile_type, is_clicked: bool = false) -> void:
	if new_type == old_type:
		return
	tile_core.tile_type = new_type
	is_hovered = false
	_disconnect_tile()
	_reset_tile()
	
	match new_type:
		G.TileType.NORMAL:
			await _apply_tile_type_NORMAL(old_type, is_clicked)
			_reconnect_tile()
		G.TileType.CHALKED:
			await _apply_tile_type_CHALKED(old_type)
			_reconnect_tile()
		G.TileType.ENDGAME:
			await _apply_tile_type_ENDGAME(old_type)
			_reconnect_tile()
		G.TileType.DEAD:
			_apply_tile_type_DEAD(old_type, is_clicked)
		G.TileType.NULL:
			_apply_tile_type_NULL()
		_:
			pass
	#print("from ", G.TileType.keys()[old_type]  , " to " , G.TileType.keys()[new_type])

func _disconnect_tile() -> void:
	if area.mouse_entered.is_connected(_on_mouse_entered):
		area.mouse_entered.disconnect(_on_mouse_entered)
	if area.mouse_exited.is_connected(_on_mouse_exited):
		area.mouse_exited.disconnect(_on_mouse_exited)
	if area.input_event.is_connected(_on_input_event):
		area.input_event.disconnect(_on_input_event)

func _reconnect_tile() -> void:
	if not area.mouse_entered.is_connected(_on_mouse_entered):
		area.mouse_entered.connect(_on_mouse_entered)
	if not area.mouse_exited.is_connected(_on_mouse_exited):
		area.mouse_exited.connect(_on_mouse_exited)
	if not area.input_event.is_connected(_on_input_event):
		area.input_event.connect(_on_input_event)

func _off_tile_visibility() -> void:
	collision_shape.disabled = true
	self.visible = false

func _on_tile_visibility() -> void:
	collision_shape.disabled = false
	self.visible = true

func _reset_tile() -> void:
	sprite.position = original_sprite_position
	sprite.rotation = original_sprite_rotation
	mesh.material_override.albedo_color.a = 1

func _apply_tile_type_NORMAL(previous_type: G.TileType, is_clicked: bool = false) -> void:
	_update_material()
	_on_tile_visibility()
	chalk.visible = false
	endgame.visible = false
	
	match previous_type:
		G.TileType.DEAD, G.TileType.NULL:
			await anim_appear_1()
		G.TileType.CHALKED:
			anim_tile_down()
			if is_clicked:
				G.set_turn(G.GameTurn.MONKE_TURN)
		_:
			pass

func _apply_tile_type_CHALKED(previous_type: G.TileType) -> void:
	_update_material()
	_on_tile_visibility()
	endgame.visible = false

	chalk.texture = G.CHALK_RESOURCES[tile_core.chalk_type]
	chalk.rotation_degrees = DIR_ROTATIONS.get(tile_core.guidance_vec, Vector3.ZERO)
	chalk.position.y = TILE_SIZE.y / 2
	chalk.visible = true
	
	match previous_type:
		G.TileType.DEAD, G.TileType.NULL:
			await anim_appear_1()
		_:
			pass

func _apply_tile_type_ENDGAME(previous_type: G.TileType) -> void:
	_update_material()
	_on_tile_visibility()
	chalk.visible = false
	
	endgame.position.y = TILE_SIZE.y / 2
	endgame.rotation.y = randf() * TAU  # TAU = 2*PI
	endgame.visible = true
	
	match previous_type:
		G.TileType.DEAD, G.TileType.NULL:
			await anim_appear_1()
		_:
			pass
	
func _apply_tile_type_DEAD(previous_type: G.TileType, is_clicked: bool = false) -> void:
	#_update_material() not needed??????
	match previous_type:
		G.TileType.NORMAL:
			if is_clicked:
				G.set_turn(G.GameTurn.MONKE_TURN)
			await anim_fall()
			_off_tile_visibility()
		_:
			_off_tile_visibility()

func _apply_tile_type_NULL() -> void:
	_off_tile_visibility()

func set_tile_state(new_state: G.TileState) -> void:
	tile_core.tile_state = new_state
#endregion
