extends Node
class_name ShapeMapper

func create_shape(shape_name: G.ShapePattern, size: Vector2i) -> Array:
	print("_create_", G.ShapePattern.keys()[shape_name])
	match shape_name:
		#G.ShapePattern.RECTANGLE:
			#return _create_rectangle(size)
		#G.ShapePattern.DIAMOND:
			#return _create_diamond(size)
		#G.ShapePattern.CIRCLE:
			#return _create_circle(size)
		#G.ShapePattern.CROSS:
			#return _create_cross(size)
		#G.ShapePattern.CANDY:
			#return _create_candy(size)
		_:
			return _create_diamond(Vector2i(9,18))

func _create_rectangle(size: Vector2i) -> Array[Array]:
	var grid: Array[Array] = []
	
	for y in range(size.y - 1):
		var row: Array = []
		for x in range(size.x):
			if y % 2 != 0 and x == size.x - 1:
				row.append(0)
			else:
				row.append(1)
		grid.append(row)
		
	return grid

func _create_diamond(size: Vector2i) -> Array[Array]:
	var grid: Array[Array] = []
	var center: Vector2 = size * 0.5
	var radius: Vector2 = center
	
	for y in range(size.y):
		var row: Array = []
		var is_odd_row: bool = y % 2 != 0
		for x in range(size.x):
			var x_pos: float = x + (0.5 if is_odd_row else 0.0)
			var dx: float = abs(x_pos - center.x) / radius.x
			var dy: float = abs(y - center.y) / radius.y
			var is_inside: bool = (dx + dy) <= 1
			row.append(1 if is_inside else 0)
		grid.append(row)
	
	return grid


func _create_circle(size: Vector2i) -> Array[Array]:
	var grid: Array[Array] = []
	var center: Vector2 = size * 0.5
	var radius: Vector2 = center
	
	for y in range(size.y):
		var is_odd_row: bool = y % 2 != 0
		var x_offset: float = 0.5 if is_odd_row else 0.0
		var row: Array = []
		for x in range(size.x):
			var nx: float = (x + x_offset - center.x) / radius.x
			var ny: float = (y - center.y) / radius.y
			var distance_squared: float = nx * nx + ny * ny
			var is_inside: bool = distance_squared <= 0.93  # 0.93 - magic number for better circle appearance
			row.append(1 if is_inside else 0)
		grid.append(row)
	
	return grid


func _create_candy(size: Vector2i) -> Array[Array]:
	var grid: Array[Array] = []
	var center: Vector2 = size * 0.5
	var max_distance: float = max(center.x, center.y)
	
	for y in range(size.y):
		var is_odd_row: bool = y % 2 == 1
		var row: Array = []
		for x in range(size.x):
			var dx: float = (x + 0.5 if is_odd_row else x) - center.x
			var dy: float = y - center.y
			var distance: float = (abs(dx) + abs(dy)) / max_distance
			var is_inside: bool = distance <= 1.0
			if y % 2 != 0 and x == size.x - 1:
				row.append(0)
			else:
				row.append(1 if is_inside else 0)
		grid.append(row)
	
	return grid


func _create_cross(size: Vector2i) -> Array[Array]:
	var grid: Array[Array] = []
	var thickness: float = max(size.x, size.y) / 8.0
	
	for y in range(size.y - 1):
		var row: Array = []
		var is_odd_row: bool = y % 2 != 0
		var k: float = float(size.x) / size.y
		for x in range(size.x):
			var real_x: float = x + (0.5 if is_odd_row else 0.0)
			var in_main: bool = abs(real_x - y * k) <= thickness
			var in_anti: bool = abs(real_x - (size.x - 1 - y * k)) <= thickness
			if y % 2 != 0 and x == size.x - 1:
				row.append(0)
			else:
				row.append(1 if (in_main or in_anti) else 0)
		if is_odd_row:
			row.append(0)
			if row.size() > size.x:
				row.pop_back()
		grid.append(row)
	
	return grid
