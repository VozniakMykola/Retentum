extends Node
class_name ShapeMapper

func create_shape(shape_name: G.ShapePattern, size: Vector2i, shore_thickness: int , center_size: int ) -> Array:
	print("_create_", G.ShapePattern.keys()[shape_name], ", shore:", shore_thickness, ", center:", center_size)
	center_size = center_size / 2
	match shape_name:
		G.ShapePattern.RECTANGLE:
			return _create_RECTANGLE(size, shore_thickness, center_size)
		G.ShapePattern.DIAMOND:
			return _create_DIAMOND(size, shore_thickness, center_size)
		G.ShapePattern.CIRCLE:
			return _create_CIRCLE(size, shore_thickness, center_size)
		G.ShapePattern.CROSS:
			return _create_CROSS(size, shore_thickness, center_size)
		G.ShapePattern.ISLAND:
			var island = _create_ISLAND(size, shore_thickness, center_size)
			return _post_process(island)
		_:
			return _create_RECTANGLE(size, shore_thickness, center_size)

func _create_RECTANGLE(size: Vector2i, shore_thickness: int, center_size: int) -> Array[Array]:
	var grid: Array[Array] = []
	var corrected_size_y = size.y - 1 #always -1 because size.y always == size.x*2 (even)
	var corrected_size_x
	
	for y in range(corrected_size_y):
		var row: Array = []
		corrected_size_x = (size.x - 1 if y % 2 != 0 else size.x)
		for x in range(corrected_size_x):
			if x == 0 or x == corrected_size_x - 1 or \
				y < G.Y_RATIO or y >= corrected_size_y - G.Y_RATIO:
				row.append(G.GenCellType.EDGE)
			elif x < shore_thickness or x >= corrected_size_x - shore_thickness or \
				y < shore_thickness * G.Y_RATIO or y >= corrected_size_y - shore_thickness * G.Y_RATIO:
				row.append(G.GenCellType.SHORE)
			else:
				row.append(G.GenCellType.LAND)
		grid.append(row)
	grid = set_tiles(grid, center_size, G.GenCellType.CENTER)
	return grid

func _create_CROSS(size: Vector2i, shore_thickness: int, center_size: int) -> Array[Array]:
	var grid: Array[Array] = []
	var thickness: float = max(size.x, size.y) / 8.0
	var corrected_size_y = size.y - 1
	var corrected_size_x
	
	var magic_size_x = size.x - 1 #idk
	
	for y in range(corrected_size_y):
		var row: Array = []
		var is_odd_row: bool = y % 2 != 0
		corrected_size_x = size.x - int(is_odd_row)
		for x in range(corrected_size_x):
			var real_x: float = x + (0.5 if is_odd_row else 0.0)
			var in_main: bool = abs(real_x - y * G.X_RATIO) <= thickness
			var in_anti: bool = abs(real_x - (magic_size_x - y * G.X_RATIO)) <= thickness
			if in_main or in_anti:
				if x == 0 or x == corrected_size_x - 1 or \
					y < G.Y_RATIO or y >= corrected_size_y - G.Y_RATIO:
					row.append(G.GenCellType.EDGE)
				elif x < shore_thickness or x >= corrected_size_x - shore_thickness or \
					y < shore_thickness * G.Y_RATIO or y >= corrected_size_y - shore_thickness * G.Y_RATIO:
					row.append(G.GenCellType.SHORE)
				else:
					row.append(G.GenCellType.LAND)
			else:
				row.append(G.GenCellType.VOID)
		grid.append(row)
	grid = set_tiles(grid, center_size, G.GenCellType.CENTER)
	return grid

func set_tiles(grid: Array[Array], center_size: int, cell_type: G.GenCellType) -> Array[Array]:
	if center_size <= 0:
		center_size = 0.5
	
	var center: Vector2 = (Vector2(grid[0].size(), grid.size()) - Vector2.ONE) * 0.5
	
	for y in range(grid.size()):
		var is_odd_row: bool = y % 2 != 0
		var x_offset = 0.5 if is_odd_row else 0.0
		
		for x in range(grid[y].size()):
			var dx = x + x_offset - center.x
			var dy = (y - center.y) / G.Y_RATIO
			var distance = sqrt(dx*dx + dy*dy)
			
			if distance <= center_size:
				grid[y][x] = cell_type
	
	return grid
	pass

func _create_CIRCLE(size: Vector2i, shore_thickness: int, center_size: int) -> Array[Array]:
	var grid: Array[Array] = []
	var corrected_size_y = size.y - 1
	var corrected_size_x
	var center: Vector2 = (Vector2(size.x, corrected_size_y) - Vector2.ONE) * 0.5
	var radius = (size.x / 2.0) - 0.5
	
	for y in range(corrected_size_y):
		var row: Array = []
		var is_odd_row: bool = y % 2 != 0
		var x_offset = 0.5 if is_odd_row else 0.0
		corrected_size_x = size.x - int(is_odd_row)
		for x in range(corrected_size_x):
			var dx = x + x_offset - center.x
			var dy = (y - center.y) / G.Y_RATIO
			var distance = sqrt(dx*dx + dy*dy) #Euclidean distance
			if distance <= radius:
				if distance >= radius - 0.7:
					row.append(G.GenCellType.EDGE)
				elif distance <= center_size:
					row.append(G.GenCellType.CENTER)
				elif distance >= radius - shore_thickness:
					row.append(G.GenCellType.SHORE)
				else:
					row.append(G.GenCellType.LAND)
			else:
				row.append(G.GenCellType.VOID)
		grid.append(row)
	return grid

func _create_DIAMOND(size: Vector2i, shore_thickness: int, center_size: int) -> Array[Array]:
	var grid: Array[Array] = []
	var corrected_size_y = size.y - 1
	var center: Vector2 = (Vector2(size.x, corrected_size_y) - Vector2.ONE) * 0.5
	var radius = (size.x / 2.0) - 0.5
	
	for y in range(corrected_size_y):
		var row: Array = []
		var is_odd_row: bool = y % 2 != 0
		var x_offset = 0.5 if is_odd_row else 0.0
		var corrected_size_x = size.x - int(is_odd_row)
		
		for x in range(corrected_size_x):
			var dx = abs(x + x_offset - center.x)
			var dy = abs((y - center.y) / G.Y_RATIO)
			var distance = dx + dy  # Manhattan distance
			
			if distance <= radius:
				if distance >= radius - 0.5:
					row.append(G.GenCellType.EDGE)
				elif distance <= center_size:
					row.append(G.GenCellType.CENTER)
				elif distance >= radius - shore_thickness:
					row.append(G.GenCellType.SHORE)
				else:
					row.append(G.GenCellType.LAND)
			else: 
				row.append(G.GenCellType.VOID)
		grid.append(row)
	return grid

func _create_ISLAND(size: Vector2i, shore_thickness: int, center_size: int) -> Array[Array]:
	var grid: Array[Array] = []
	var corrected_size_y = size.y - 1
	var corrected_size_x
	var center: Vector2 = (Vector2(size.x, corrected_size_y) - Vector2.ONE) * 0.5
	var radius = (size.x / 2.0) - 0.5
	
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.3
	noise.fractal_octaves = 5
	
	for y in range(corrected_size_y):
		var row: Array = []
		var is_odd_row: bool = y % 2 != 0
		var x_offset = 0.5 if is_odd_row else 0.0
		corrected_size_x = size.x - int(is_odd_row)
		for x in range(corrected_size_x):
			var is_noise = noise.get_noise_2d(x, y)
			var dx = x + x_offset - center.x
			var dy = (y - center.y) / G.Y_RATIO
			var distance = sqrt(dx*dx + dy*dy) #Euclidean distance
			if distance <= radius && (is_noise > 0.0 || distance <= radius / 3):
				if distance >= radius - 0.7:
					row.append(G.GenCellType.EDGE)
				elif distance <= center_size:
					row.append(G.GenCellType.CENTER)
				elif distance >= radius - shore_thickness:
					row.append(G.GenCellType.SHORE)
				else:
					row.append(G.GenCellType.LAND)
			else:
				row.append(G.GenCellType.VOID)
		grid.append(row)
	return grid

func _post_process(grid: Array[Array]) -> Array[Array]:
	var new_grid = grid.duplicate(true)
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var neighbors = _count_non_void_neighbors(grid, x, y)
			# 1
			if grid[y][x] == G.GenCellType.VOID and neighbors >= 4:
				new_grid[y][x] = G.GenCellType.LAND
			# 2
			elif grid[y][x] != G.GenCellType.VOID and neighbors < 2:
				new_grid[y][x] = G.GenCellType.VOID
	return new_grid

func _count_non_void_neighbors(grid: Array[Array], x: int, y: int) -> int:
	var count = 0
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if dx == 0 and dy == 0: continue  # Пропускаємо поточну клітинку
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and ny >= 0 and ny < grid.size() and nx < grid[ny].size():
				if grid[ny][nx] != G.GenCellType.VOID:
					count += 1
	return count

#region Suggested Patterns / Pattern Ideas
# - ISLAND
# - STAR
# - HEXAGON
# - CANDY
#endregion
