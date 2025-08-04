extends Node3D

@export_group("Game")
var game_builder: GameBuilder = GameBuilder.new()
var game_config: GameConfig
var level_map: Dictionary
const GAME_SCENE = preload("res://scenes/game/game.tscn") 
var game_center: Vector3 = Vector3.ZERO

@onready var grid_map = POOLGRID.grid_map
@onready var iso_camera: Camera3D = $IsoCamera
@onready var monke: Monke = $Monke
@onready var timer: Timer = $Timer
@onready var light: DirectionalLight3D = $DirectionalLight3D

func _ready() -> void:
	initialize_game()

func initialize_game() -> void:
	game_config = game_builder.generate_config()
	level_map = game_builder.generate_field()
	setup_camera()
	pre_generate()
	await post_generate()
	monke.grid_map = grid_map
	monke.current_cell = game_builder.centers.pick_random()
	monke.init()
	timer.start()

func pre_generate():
	if not is_instance_valid(grid_map) or grid_map.get_parent() != self:
		add_child(grid_map)
	POOLGRID.reset_tiles()

func post_generate():
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

func setup_camera():
	#tmp but works
	var matrix_size = grid_map.get_true_from_staggered(game_config.world_size)
	var grid_size = Vector2(matrix_size.x-1, (matrix_size.y-1) / G.Y_RATIO) * grid_map.cell_size
	
	var game_center = Vector3(grid_size.x/2 - 0.5, grid_map.y_index, grid_size.y/2)
	
	var diagonal = Vector2(grid_size.x, grid_size.y).length()
	var camera_height = diagonal * 0.71
	var camera_offset = diagonal * 0.5
	var size_offset = diagonal * 0.55

	iso_camera.position = Vector3(
		game_center.x + camera_offset,
		camera_height,
		game_center.z + camera_offset
	)
	iso_camera.size = size_offset
	iso_camera.rotation_degrees = Vector3(-45, 45, 0)

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

func _on_timer_timeout() -> void:
	monke.monke_turn()
