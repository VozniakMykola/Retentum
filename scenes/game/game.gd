extends Node3D

@export_group("Game")
var game_builder: GameBuilder = GameBuilder.new()
var game_config: Dictionary

@onready var grid_map: OrthoGridMap = $MainGridMap

const TILE_SCENE = preload("res://src/tiles/tile.tscn")
const GAME_SCENE = preload("res://scenes/game/game.tscn") 

func _ready() -> void:
	initialize_game()

func initialize_game() -> void:
	game_config = game_builder.start_new_game()
	generate_level()

func generate_level():
	var diagonals = {}
	for coord in game_config:
		var diag_index = coord.x * 2 + (coord.y % 2) + coord.y
		if not diagonals.has(diag_index):
			diagonals[diag_index] = []
		diagonals[diag_index].append(coord)
	
	# 2. Отримуємо відсортовані індекси діагоналей
	var sorted_diag_indices = diagonals.keys()
	sorted_diag_indices.sort()  # Сортуємо за зростанням
	
	# 3. Заповнюємо діагоналі в правильному порядку
	for diag_index in sorted_diag_indices:
		# Сортуємо тайли всередині діагоналі (за Y або X за потребою)
		diagonals[diag_index].sort_custom(func(a, b): return a.y < b.y)
		
		# Створюємо всі тайли діагоналі
		for coord in diagonals[diag_index]:
			var tile = TILE_SCENE.instantiate()
			tile.tile_data = game_config[coord]
			grid_map.set_cell_item(coord, tile)
		
		await get_tree().create_timer(0.1).timeout  # Затримка між діагоналями
func restart_game() -> void:
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
