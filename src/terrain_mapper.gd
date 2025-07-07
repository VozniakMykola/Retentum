extends Node
class_name TerrainMapper

var rng = RandomNumberGenerator.new()

func map_terrain(terrain_name: G.TerrainPattern, palette: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	var height = shape_grid.size()
	if height == 0: return result
	var width = shape_grid[0].size()
	
	var pattern_tiles = []
	match terrain_name:
		G.TerrainPattern.SOLID:
			pattern_tiles = _get_tiles_for_pattern(palette, 1)
			return _map_SOLID(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.CHECKERED:
			pattern_tiles = _get_tiles_for_pattern(palette, 2)
			return _map_CHECKERED(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.DOTTED:
			pattern_tiles = _get_tiles_for_pattern(palette, 2)
			return _map_DOTTED(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.HEARTS:
			pattern_tiles = _get_tiles_for_pattern(palette, 2)
			return _map_HEARTS(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.PLAID:
			pattern_tiles = _get_tiles_for_pattern(palette, 3)
			return _map_PLAID(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.PATCHY:
			pattern_tiles = _get_tiles_for_pattern(palette, palette.size() if palette.size() > 0 else 1)
			return _map_PATCHY(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.NOISE:
			pattern_tiles = palette.duplicate()
			return _map_NOISE(pattern_tiles, shape_grid, width, height)
		_:
			return {}

func _get_tiles_for_pattern(palette: Array, required_count: int) -> Array:
	if palette.size() == 0:
		return []
	
	var tiles = []
	
	# Якщо палітра менша за необхідну кількість
	if palette.size() < required_count:
		# Копіюємо всі наявні тайли
		tiles = palette.duplicate()
		# Додаємо випадкові тайли з палітри, щоб заповнити необхідну кількість
		while tiles.size() < required_count:
			tiles.append(palette[rng.randi_range(0, palette.size() - 1)])
	else:
		# Вибір випадкових унікальних тайлів з палітри
		var indices = range(palette.size())
		indices.shuffle()
		for i in range(required_count):
			tiles.append(palette[indices[i]])
	
	return tiles

# SOLID: всі ненульові клітинки одним кольором
func _map_SOLID(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() == 0: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				result[Vector2i(x, y)] = tiles[0]
	return result

# CHECKERED: шахматний візерунок
func _map_CHECKERED(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < 2: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var index = (x + y) % 2
				result[Vector2i(x, y)] = tiles[index]
	return result

# DOTTED: крапковий візерунок (кожна 4-та клітинка іншим кольором)
func _map_DOTTED(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < 2: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				if x % 2 == 0 && y % 2 == 0:
					result[Vector2i(x, y)] = tiles[1]
				else:
					result[Vector2i(x, y)] = tiles[0]
	return result

# HEARTS: серцевидний візерунок (спеціальні позиції)
func _map_HEARTS(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < 2: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				# Визначаємо позиції для "сердечок"
				var is_heart = false
				
				# Простий шаблон сердечка (можна змінити на складніший)
				if y > 0 && x > 0 && x < width - 1:
					# Верхня частина серця
					is_heart = (y == 1 && (x == 1 || x == width - 2)) || \
						(y == 2 && (x == 0 || x == 2 || x == width - 3 || x == width - 1)) || \
						(y == 3 && x >= 1 && x <= width - 2)
				
				if is_heart:
					result[Vector2i(x, y)] = tiles[1]
				else:
					result[Vector2i(x, y)] = tiles[0]
	return result

# PLAID: тканинний/клітковий візерунок
func _map_PLAID(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < 3: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var index = 0
				
				# Смуги по горизонталі
				if y % 4 == 0:
					index = 1
				
				# Смуги по вертикалі
				if x % 4 == 0:
					index = 2 if index == 0 else 0
				
				result[Vector2i(x, y)] = tiles[index]
	return result

# PATCHY: клаптиковий випадковий візерунок
func _map_PATCHY(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() == 0: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var random_index = rng.randi_range(0, tiles.size() - 1)
				result[Vector2i(x, y)] = tiles[random_index]
	return result

func _map_NOISE(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() == 0: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var random_index = rng.randi_range(0, tiles.size() - 1)
				result[Vector2i(x, y)] = tiles[random_index]
	return result
