extends Node3D

const GAME_SCENE = preload("res://scenes/game/game.tscn") 

var game_builder: GameBuilder = GameBuilder.new()
var game_config: GameConfig
var level_map: Dictionary
var game_center: Vector3 = Vector3.ZERO
var game_diagonal: float

@onready var grid_map = POOLGRID.grid_map
@onready var iso_camera: Camera3D = $IsoCamera
@onready var monke: Monke = $Monke
@onready var light: DirectionalLight3D = $DirectionalLight3D
@onready var void_bottom: MeshInstance3D = $EnviObjects/VoidBottom

func _ready() -> void:
	G.turn_next.connect(_on_turn_next)
	initialize_game()

func initialize_game() -> void:
	G.set_turn(G.GameTurn.NONE_TURN)
	
	game_config = game_builder.generate_config()
	level_map = game_builder.generate_field()
	get_game_sizes(game_builder.true_map_size)
	setup_camera()
	setup_environment()
	add_map_to_scene()
	await map_fill()
	add_monke()
	
	G.set_turn(G.GameTurn.PLAYER_TURN)

func get_game_sizes(map_size: Vector2i) -> void:
	var map_center: Vector2 = grid_map.get_true_from_staggered_float(Vector2(map_size.x/2, map_size.y/2))
	game_center = Vector3(map_center.x * grid_map.cell_size.x, grid_map.y_index, map_center.y * grid_map.cell_size.y)
	
	game_diagonal = (Vector2(map_size) * grid_map.cell_size).length()

func setup_camera() -> void:
	var size_offset = 0.6
	iso_camera.size = game_diagonal * size_offset
	
	iso_camera.position = Vector3(
		game_center.x + game_diagonal / 2,
		game_diagonal / 1.4,
		game_center.z + game_diagonal / 2
	)
	
	iso_camera.rotation_degrees = Vector3(-45, 45, 0)

func setup_environment() -> void:
	void_bottom.position = Vector3(game_center.x - 6, game_center.y - 10, game_center.z - 6)

func add_map_to_scene() -> void:
	if not is_instance_valid(grid_map) or grid_map.get_parent() != self:
		add_child(grid_map)
	POOLGRID.reset_tiles()

func map_fill() -> void:
	var all_coords = level_map.keys()
	var row_delay = 0.05
	var sort_direction = randi() % 4
	
	var sort_functions = [
		# top to bottom
		func(a, b): 
			if a.y < b.y: return true
			if a.y > b.y: return false
			return false,
		# bottom to top
		func(a, b): 
			if a.y > b.y: return true
			if a.y < b.y: return false
			return false,
		# left to right (X with even Y)
		func(a, b): 
			if a.x != b.x: return a.x < b.x
			return a.y % 2 < b.y % 2,  # Спершу парні Y
		# right to left (X with odd Y)
		func(a, b): 
			if a.x != b.x: return a.x > b.x
			return a.y % 2 > b.y % 2   # Спершу непарні Y
	]
	all_coords.sort_custom(sort_functions[sort_direction])
	
	var current_row = null
	var first_half_done = false
	
	for coord in all_coords:
		var row_key = coord.y if sort_direction < 2 else coord.x
		
		if current_row != row_key:
			current_row = row_key
			first_half_done = false
			await get_tree().create_timer(row_delay).timeout
		
		if sort_direction >= 2:
			var is_first_half = (coord.y % 2 == 0) == (sort_direction == 2)
			if is_first_half != first_half_done:
				first_half_done = is_first_half
				await get_tree().create_timer(row_delay * 0.5).timeout
		
		var tile = grid_map.get_cell_item(coord) as Tile
		tile.tile_config = level_map[coord]

func add_monke() -> void:
	monke.grid_map = grid_map
	monke.current_cell = game_builder.centers.pick_random()
	monke.init()

func restart_game() -> void:
	if grid_map.get_parent() == self:
		remove_child(grid_map)
	var new_game = GAME_SCENE.instantiate()
	get_tree().root.add_child(new_game)
	get_tree().current_scene = new_game
	queue_free()

func _on_win_pressed() -> void:
	P.record_session_result(true)
	restart_game()

func _on_lose_pressed() -> void:
	P.record_session_result(false)
	restart_game()

func _on_turn_next(turn: G.GameTurn) -> void:
	if turn == G.GameTurn.MONKE_TURN:
		monke.monke_turn()
