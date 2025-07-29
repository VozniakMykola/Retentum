class_name Tile
extends GridObject

signal tile_hovered(tile: Tile)
signal tile_unhovered(tile: Tile)
signal tile_clicked(tile: Tile, mouse_button: int)

#From export
@export var tile_config: TileConfig:
	set(value):
		tile_config = value
		tile_res = tile_config.tile_res
		current_tile_state = tile_config.tile_state
		current_tile_type = tile_config.tile_type
		current_chalk = tile_config.chalk_type
		current_guidance_vec = tile_config.guidance_vec

var tile_res: TileResource:
	set(value):
		if tile_res == value:
			return
		tile_res = value
		if is_inside_tree():
			_apply_tile_res()

#Settings
var tile_size: Vector3 = Vector3(1.0, 0.2, 1.0)
var hitbox_size: Vector3
var hitbox_y_offset: float

#Functionality
var current_tile_type: G.TileType = G.TileType.DEAD:
	set(value):
		current_tile_type = value
		if is_inside_tree():
			match current_tile_type:
				G.TileType.NORMAL:
					collision_shape.disabled = false
					chalk.visible = false
					endgame.visible = false
				G.TileType.CHALKED:
					collision_shape.disabled = false
					chalk.visible = true
					endgame.visible = false
					print 
					chalk.texture = G.CHALK_RESOURCES[current_chalk]
					if current_chalk == G.ChalkType.GUIDANCE:
						chalk.rotation_degrees = DIR_ROTATIONS.get(current_guidance_vec, Vector3.ZERO)
						print(chalk.rotation_degrees)
				G.TileType.ENDGAME:
					collision_shape.disabled = false
					chalk.visible = false
					endgame.visible = true
				G.TileType.DEAD:
					collision_shape.disabled = true
					chalk.visible = false
					endgame.visible = false
				_:
					pass

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

var current_chalk = null
var current_guidance_vec: Vector2i

var tile_behavior: Dictionary = {
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
			"on_mouse_enter": func(): pass,
			"on_mouse_exit": func(): pass,
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

@onready var area: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

@onready var sprite: Node3D = $Sprite
@onready var chalk: Sprite3D = $Sprite/Chalk
@onready var mesh: MeshInstance3D = $Sprite/Mesh
@onready var endgame: Node3D = $Sprite/Endgame

#region Consts
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

const DIR_ROTATIONS = {
	Vector2i.UP: Vector3(-90.0, 45.0, 0.0),
	Vector2i.DOWN: Vector3(90.0, 45.0, 0.0),
	Vector2i.LEFT: Vector3(90.0, -45.0, 0.0),
	Vector2i.RIGHT: Vector3(-90.0, -45.0, 0.0),
	Vector2i.UP + Vector2i.LEFT: Vector3(90.0, -90.0, 0.0),
	Vector2i.UP + Vector2i.RIGHT: Vector3(-90.0, 0.0, 0.0),
	Vector2i.DOWN + Vector2i.LEFT: Vector3(90.0, 0.0, 0.0),
	Vector2i.DOWN + Vector2i.RIGHT: Vector3(-90.0, -90.0, 0.0)
}

var original_sprite_position: Vector3
var lifted_sprite_position: Vector3
var is_hovered: bool = false
var current_tween: Tween

#region Setup
func _ready() -> void:
	current_tile_type = G.TileType.DEAD
	hitbox_y_offset = LIFT_HEIGHT/2
	hitbox_size = Vector3(tile_size.x, tile_size.y + LIFT_HEIGHT, tile_size.z)
	
	original_sprite_position = sprite.position
	lifted_sprite_position = original_sprite_position + Vector3(0, LIFT_HEIGHT, 0)
	
	if tile_res:
		_apply_tile_res()
	var random_rotation = randi() % 4 * 90
	mesh.rotation_degrees.y = random_rotation
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	await anim_appear_1()
	tile_config = tile_config

func _apply_tile_res() -> void:
	if !tile_res:
		return
	if mesh.material_override != tile_res.get_material():
		mesh.material_override = tile_res.get_material()
	mesh.mesh.size = tile_size
	mesh.material_override = tile_res.get_material()
	chalk.position.y = tile_size.y / 2
	endgame.position.y = tile_size.y / 2
	endgame.rotation.y = randf() * TAU  # TAU = 2*PI
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
	var config = tile_behavior.get(current_tile_state, {})
	return config.get(
		current_tile_type if current_tile_state != G.TileState.OCCUPIED else "_default", 
		{}
	)
#endregion

#region Interractions NORMAL

func _on_mouse_entered_normal():
	anim_tile_up()
	
func _on_mouse_exited_normal():
	anim_tile_down()

func _on_click_normal():
	set_tile_type(G.TileType.DEAD)
	anim_fall()
	pass
#endregion

#region Interractions CHALKED & BLOCKED
func _on_click_chalked():
	set_tile_type(G.TileType.NORMAL)
	pass

func _on_click_blocked():
	#shaking
	pass
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
	
	current_tween.tween_property(
		sprite, 
		"position:y", 
		lifted_sprite_position.y + LIFT_OVERSHOOT, 
		TICK_TACK_SPEED
	)
	
	current_tween.tween_callback(anim_floating)

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
	var new_material = mesh.material_override
	mesh.material_override = new_material
	current_tween.tween_property(new_material, "albedo_color:a", 0.0, FALL_DURATION*0.70).set_delay(FALL_DURATION*0.25)

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

	#current_tween.set_parallel(true)

	await current_tween.finished

#endregion

#region States logic

func set_tile_type(new_type: G.TileType):
	current_tile_type = new_type

func set_tile_state(new_state: G.TileState):
	current_tile_state = new_state
#endregion
