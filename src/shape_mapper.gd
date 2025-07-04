extends Node
class_name ShapeMapper

func create_shape(shape_name: G.ShapePattern, size: Vector2i) -> Array:
	match shape_name:
		G.ShapePattern.RECTANGLE:
			return _create_RECTANGLE(size)
		G.ShapePattern.DIAMOND:
			return _create_DIAMOND(size)
		G.ShapePattern.CIRCLE:
			return _create_CIRCLE(size)
		G.ShapePattern.ISLANDS:
			return _create_ISLANDS(size)
		_:
			pass
	return []

func _create_RECTANGLE(size: Vector2i):
	var grid = []
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			row.append(1)
		grid.append(row)
	return grid

func _create_DIAMOND(size: Vector2i):
	var grid = []
	var center = Vector2(size.x / 2.0, size.y / 2.0)
	var radius = min(size.x, size.y) / 2.0
	
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			var dx = abs(x - center.x)
			var dy = abs(y - center.y)
			if dx + dy <= radius:
				row.append(1)
			else:
				row.append(0)
		grid.append(row)
	return grid

func _create_CIRCLE(size: Vector2i) -> Array:
	var grid = []
	var center = Vector2(size.x / 2.0, size.y / 2.0)
	var radius = min(size.x, size.y) / 2.0
	var radius_sq = radius * radius
	
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			var dx = x - center.x
			var dy = y - center.y
			if dx*dx + dy*dy <= radius_sq:
				row.append(1)
			else:
				row.append(0)
		grid.append(row)
	return grid

func _create_ISLANDS(size: Vector2i) -> Array:
	var grid = []
	# Ініціалізація пустої сітки
	for y in range(size.y):
		grid.append([])
		grid[y].resize(size.x)
		for x in range(size.x):
			grid[y][x] = 0
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var islands_count = rng.randi_range(1, 6)
	
	# Генерація островів
	for i in range(islands_count):
		var pos = Vector2i(
			rng.randi_range(0, size.x - 1),
			rng.randi_range(0, size.y - 1)
		)
		var island_size = Vector2i(
			rng.randi_range(1, max(1, size.x / 4)),
			rng.randi_range(1, max(1, size.y / 4))
		)
		
		# Заповнення прямокутника
		for y in range(pos.y, min(pos.y + island_size.y, size.y)):
			for x in range(pos.x, min(pos.x + island_size.x, size.x)):
				grid[y][x] = 1
	return grid
