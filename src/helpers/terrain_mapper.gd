extends Node
class_name TerrainMapper

func map_terrain(terrain_name: G.TerrainPattern, palette: Array, shape_grid: Array, is_sequentially: bool) -> Dictionary:
	var result = {}
	var height = shape_grid.size()
	if height == 0: return result
	var width = shape_grid[0].size()
	var pattern_tiles = []
	print("_terrain_", G.TerrainPattern.keys()[terrain_name])
	pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name], is_sequentially)
	match terrain_name:
		G.TerrainPattern.SOLID:
			return _map_SOLID(pattern_tiles, shape_grid)
		G.TerrainPattern.CHECKERED:
			return _map_CHECKERED(pattern_tiles, shape_grid)
		G.TerrainPattern.DOTTED:
			return _map_DOTTED(pattern_tiles, shape_grid)
		G.TerrainPattern.PLAID:
			return _map_PLAID(pattern_tiles, shape_grid)
		G.TerrainPattern.PATCHY:
			return _map_PATCHY(pattern_tiles, shape_grid, 7, 6)
		G.TerrainPattern.SQUARES:
			return _map_PATCHY(pattern_tiles, shape_grid, 5, 3)
		G.TerrainPattern.ARCHIPELAGO:
			return _map_ARCHIPELAGO(pattern_tiles, shape_grid)
		G.TerrainPattern.ZEBRA_V:
			var zebra_size = randi_range(1, 3)
			return _map_ZEBRA_V(pattern_tiles, shape_grid, zebra_size)
		G.TerrainPattern.ZEBRA_H:
			var zebra_size = randi_range(1, 3)
			return _map_ZEBRA_H(pattern_tiles, shape_grid, zebra_size)
		G.TerrainPattern.NOISE:
			var palette_size = palette.size()
			var random_tile_count = randi_range(2, palette_size)
			pattern_tiles = _get_tiles_for_pattern(palette, random_tile_count, is_sequentially)
			return _map_NOISE(pattern_tiles, shape_grid)
		G.TerrainPattern.BIG_HEART:
			return _map_shape_single(pattern_tiles, shape_grid, big_heart_template_even, big_heart_template_odd)
		G.TerrainPattern.HEARTS:
			return _map_shape(pattern_tiles, shape_grid, heart_template_even, heart_template_odd, Vector2i(1,2), Vector2i(3,6), false)
		_:
			return _map_SOLID(pattern_tiles, shape_grid)

const SHAPE_ELEMENT_COUNT: Dictionary = {
	G.TerrainPattern.SOLID: 1,
	G.TerrainPattern.CHECKERED: 2,
	G.TerrainPattern.DOTTED: 2,
	G.TerrainPattern.HEARTS: 2,
	G.TerrainPattern.PLAID: 2, #3
	G.TerrainPattern.PATCHY: 4,
	G.TerrainPattern.NOISE: -1,
	G.TerrainPattern.ZEBRA_V: 2,
	G.TerrainPattern.ZEBRA_H: 2,
	G.TerrainPattern.ARCHIPELAGO: 2,
	G.TerrainPattern.BIG_HEART: 2,
	G.TerrainPattern.SQUARES: 2,
}

#region Shape Templates
var heart_template_even: Array[Vector2i] = [
	Vector2i(0, 0), 
	Vector2i(-1, -1), 
	Vector2i(0, -1),
]

var heart_template_odd: Array[Vector2i] = [
	Vector2i(0, 0),  
	Vector2i(0, -1), 
	Vector2i(1, -1),
]

var big_heart_template_even: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, -1),
	Vector2i(-1, -1),
	
	Vector2i(0, 2),
	Vector2i(0, 1), 
	Vector2i(-1, 1),
	
	Vector2i(1, 0),
	Vector2i(-1, 0),
]

var big_heart_template_odd: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, -1),
	Vector2i(1, -1),
	
	Vector2i(0, 2),
	Vector2i(0, 1), 
	Vector2i(1, 1),
	
	Vector2i(1, 0),
	Vector2i(-1, 0),
]

const SQUARE_TEMPLATE_KEYS: Array = ["s", "m", "l"]
var square_templates: Dictionary = {
	"s": {
		"odd": [
			Vector2i(0, 0), 
			Vector2i(0, -1), 
			Vector2i(1, -1), 
			Vector2i(0, -2)
			],
		"even": 
			[
			Vector2i(0, 0), 
			Vector2i(0, -1), 
			Vector2i(-1, -1),
			Vector2i(0, -2)
			]
	},
	"m": {
		"odd": [
			Vector2i(0, 0), 
			Vector2i(0, -1), 
			Vector2i(1, -1), 
			Vector2i(0, -2),
			
			Vector2i(0, 2),
			Vector2i(0, 1), 
			Vector2i(1, 1),
			Vector2i(1, 0),
			Vector2i(-1, 0),
			],
		"even": [
			Vector2i(0, 0), 
			Vector2i(0, -1), 
			Vector2i(-1, -1),
			Vector2i(0, -2),
			
			Vector2i(0, 2),
			Vector2i(0, 1), 
			Vector2i(-1, 1),
			Vector2i(1, 0),
			Vector2i(-1, 0),
			]
	},
	"l": {
		"odd": [
			Vector2i(0, 0), 
			Vector2i(0, -1), 
			Vector2i(1, -1), 
			Vector2i(0, -2),
			
			Vector2i(0, 2),
			Vector2i(0, 1), 
			Vector2i(1, 1),
			Vector2i(1, 0),
			Vector2i(-1, 0),
			
			Vector2i(-1, 1), 
			Vector2i(-1, 2), 
			Vector2i(0, 3), 
			Vector2i(0, 4), 
			Vector2i(1, 3), 
			Vector2i(1, 2), 
			Vector2i(2, 1), 
			],
		"even": [
			Vector2i(0, 0), 
			Vector2i(0, -1), 
			Vector2i(-1, -1),
			Vector2i(0, -2),
			
			Vector2i(0, 2),
			Vector2i(0, 1), 
			Vector2i(-1, 1),
			Vector2i(1, 0),
			Vector2i(-1, 0),
			
			Vector2i(-2, 1), 
			Vector2i(-1, 2), 
			Vector2i(-1, 3), 
			Vector2i(0, 4), 
			Vector2i(0, 3), 
			Vector2i(1, 2), 
			Vector2i(1, 1), 
			]
	},
	#"xl": {}
}
#endregion

#region Active Patterns
#approved
func _get_tiles_for_pattern(palette: Array, required_count: int, is_sequentially: bool) -> Array:
	if palette.is_empty():
		return []
	
	var tiles = palette.duplicate()
	
	if !is_sequentially:
		tiles.shuffle()
	
	if palette.size() < required_count:
		while tiles.size() < required_count:
			tiles.append(palette[randi() % palette.size()])
	else:
		tiles.slice(0, required_count)
	
	return tiles

func _put_res_in_config(tile_res: TileResource) -> TileConfig:
	var config = TileConfig.new()
	config.tile_res = tile_res
	return config

#approved
func _map_SOLID(tiles: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.SOLID]: 
		return result
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				result[Vector2i(x, y)] = _put_res_in_config(tiles[0])
	return result

#approved
func _map_NOISE(tiles: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	if tiles.is_empty(): return result
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				var random_index = randi() % tiles.size() #cr: randi_range(0, tiles.size() - 1)
				result[Vector2i(x, y)] = _put_res_in_config(tiles[random_index])
	return result

#approved
func _map_CHECKERED(tiles: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.CHECKERED]: return result
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				var index = y % 2
				result[Vector2i(x, y)] = _put_res_in_config(tiles[index])
	return result

#approved
func _map_PLAID(tiles: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.PLAID]: return result
	
	var max_dim = shape_grid.size()
	var interval = range(-max_dim, max_dim + 1)
	var count = interval.size() / 3
	interval.shuffle()
	
	var random_set = {}
	for i in range(count):
		random_set[interval[i]] = true
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				var x_ego = x * 2 + (1 if y % 2 == 1 else 0)
				if random_set.has(x_ego + y) or random_set.has(x_ego - y):
					result[Vector2i(x, y)] = _put_res_in_config(tiles[1])
				else:
					result[Vector2i(x, y)] = _put_res_in_config(tiles[0])
	return result

#approved
func _map_DOTTED(tiles: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.DOTTED]: return result
	
	var used_cords = {}
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			var pos = Vector2i(x, y)
			if shape_grid[y][x] != G.GenCellType.VOID:
				if not used_cords.has(pos):
					result[pos] = _put_res_in_config(tiles[0])
				if (x - 1) % 3 == 0 and (y - 2) % 6 == 0:
					var new_x = x + randi_range(-1, 0)
					var new_y = y + randi_range(-1, 1)
					var new_pos = Vector2i(new_x, new_y)
					if new_y >= 0 and new_y < shape_grid.size() and new_x >= 0 and new_x < shape_grid[new_y].size() and shape_grid[new_y][new_x] != G.GenCellType.VOID:
							result[new_pos] = _put_res_in_config(tiles[1])
							used_cords[new_pos] = true
	return result

#approved
func _map_shape(tiles: Array, shape_grid: Array, template_even: Array[Vector2i], template_odd: Array[Vector2i], coord_offset: Vector2i, spacing: Vector2i, is_random: bool = false) -> Dictionary:
	var result = {}
	if tiles.size() < 2: 
		return result
	
	var y_size = shape_grid.size()
	
	for y in range(y_size):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				result[Vector2i(x, y)] = _put_res_in_config(tiles[0])

	for center_y in range(coord_offset.y, y_size, spacing.y):
		for center_x in range(coord_offset.x, shape_grid[center_y].size(), spacing.x):
			
			if is_random:
				center_x += randi_range(-1, 0)
				center_y += randi_range(1, 1)
			
			var template = template_even if center_y % 2 == 0 else template_odd
			
			for rel_pos in template:
				var px = center_x + rel_pos.x
				var py = center_y + rel_pos.y
				
				if py >= 0 and py < y_size and px >= 0 and px < shape_grid[py].size():
					if shape_grid[py][px] != G.GenCellType.VOID:
						result[Vector2i(px, py)] = _put_res_in_config(tiles[1])
	
	return result

#approved
func _map_shape_single(tiles: Array, shape_grid: Array, template_even: Array[Vector2i], template_odd: Array[Vector2i], is_centered: bool = true) -> Dictionary:
	var result = {}
	if tiles.size() < 2: 
		return result
	
	var y_size = shape_grid.size()
	
	for y in range(y_size):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				result[Vector2i(x, y)] = _put_res_in_config(tiles[0])
	
	var center: Vector2i
	
	if is_centered:
		center = Vector2i(shape_grid[0].size()/2, y_size/2)
	else:
		var x_margin: int = shape_grid[0].size() / 3
		var y_margin: int = y_size / 3
		var cx = randi_range(x_margin, shape_grid[0].size() - x_margin)
		var cy = randi_range(y_margin, y_size - y_margin)
		center = Vector2i(cx, cy)
		
	var template = template_even if center.y % 2 == 0 else template_odd
	
	for rel_pos in template:
		var px = center.x + rel_pos.x
		var py = center.y + rel_pos.y
		
		if py >= 0 and py < y_size and px >= 0 and px < shape_grid[py].size():
			if shape_grid[py][px] != G.GenCellType.VOID:
				result[Vector2i(px, py)] = _put_res_in_config(tiles[1])
	
	return result

func _map_PATCHY(tiles: Array, shape_grid: Array, spawn_freq: int = 5, margin_part: int = 6) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.PATCHY]: return result
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				result[Vector2i(x, y)] = _put_res_in_config(tiles[0])
	
	var x_margin: int = shape_grid[1].size() / margin_part
	var y_margin: int = shape_grid.size() / margin_part
	var count = shape_grid.size() / spawn_freq
	var tiles_trimmed = tiles.slice(1)
	
	var random_templates = []
	for i in range(count):
		var random_key = SQUARE_TEMPLATE_KEYS[randi_range(0, SQUARE_TEMPLATE_KEYS.size() - 1)]
		random_templates.append(random_key)
	
	# sort according to SQUARE_TEMPLATE_KEYS
	random_templates.sort_custom(func(a, b): 
		return SQUARE_TEMPLATE_KEYS.find(a) > SQUARE_TEMPLATE_KEYS.find(b)
	)
	
	
	for i in range(count):
		var center_x = randi_range(x_margin, shape_grid[1].size() - x_margin - 1)
		var center_y = randi_range(y_margin, shape_grid.size() - y_margin - 1)
		
		var random_template = square_templates[random_templates[i]]
		var template = random_template["even"] if center_y % 2 == 0 else random_template["odd"]
		var selected_tile = tiles_trimmed[i % tiles_trimmed.size()]
		
		for rel_pos in template:
			var px = center_x + rel_pos.x
			var py = center_y + rel_pos.y
			
			if py >= 0 and py < shape_grid.size() and px >= 0 and px < shape_grid[py].size():
				if shape_grid[py][px] != G.GenCellType.VOID:
					result[Vector2i(px, py)] = _put_res_in_config(selected_tile)
	
	return result
#endregion

#region NOT USED patterns

#approved
func _map_ARCHIPELAGO(tiles: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.ARCHIPELAGO]: 
		return result
	
	var max_dim = shape_grid.size()
	var interval = range(-max_dim, max_dim + 1)
	var count = int(interval.size() / 4)
	interval.shuffle()
	
	var random_set = {}
	for i in range(count):
		random_set[interval[i]] = true
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				if random_set.has(x + y) or random_set.has(x - y):
					result[Vector2i(x, y)] = _put_res_in_config(tiles[0])
				else:
					result[Vector2i(x, y)] = _put_res_in_config(tiles[1])
	return result

#approved
func _map_ZEBRA_V(tiles: Array, shape_grid: Array, zebra_size = 1) -> Dictionary:
	var result = {}
	var tile_count = tiles.size()
	if tile_count < SHAPE_ELEMENT_COUNT[G.TerrainPattern.ZEBRA_V]: return result
	
	# Handle invalid zebra_size
	zebra_size = maxi(1, zebra_size)
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				var index = (x / zebra_size) % tile_count
				result[Vector2i(x, y)] = _put_res_in_config(tiles[index])
	return result

#approved
func _map_ZEBRA_H(tiles: Array, shape_grid: Array, zebra_size = 1) -> Dictionary:
	var result = {}
	var tile_count = tiles.size()
	if tile_count < SHAPE_ELEMENT_COUNT[G.TerrainPattern.ZEBRA_H]: return result
	
	# Handle invalid zebra_size
	zebra_size = maxi(1, zebra_size)
	var corrected_zebra_size = zebra_size * G.Y_RATIO
	
	for y in range(shape_grid.size()):
		for x in range(shape_grid[y].size()):
			if shape_grid[y][x] != G.GenCellType.VOID:
				var index = (y / corrected_zebra_size) % tile_count
				result[Vector2i(x, y)] = _put_res_in_config(tiles[index])
	return result

#endregion

#region Suggested Patterns / Pattern Ideas

# - Spiral
# - QUINCUNX
# - harlequin
# - Barberpole (r/l)
# - Jimmies (2 by 1 pixels in diagonal)
# - _map_PLAID_3X+
# - _map_DOTTED_STRONG (without random)

#need research
#func _map_PLAID_3X(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	#var result = {}
	#if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.PLAID]: return result
	#
	#var interval = range(-max(width, height), max(width, height) + 1)
	#var count = interval.size() / 3
	#interval.shuffle()
	#var random_coords = interval.slice(0, count)
	#var tiles_trimmed = tiles.slice(1)
	#
	#for y in range(height):
		#for x in range(width):
			#if shape_grid[y][x] != 0:
				#var x_ego = x * 2 + (1 if int(y) % 2 == 1 else 0)
				#if  (x_ego + y) in random_coords:
					#var tile_index = random_coords.find(x_ego + y) % tiles_trimmed.size()
					#result[Vector2i(x, y)] = tiles_trimmed[tile_index]
				#elif (x_ego - y) in random_coords:
					#var tile_index = random_coords.find(x_ego + y) % tiles_trimmed.size()
					#result[Vector2i(x, y)] = tiles_trimmed[tile_index]
				#else:
					#result[Vector2i(x, y)] = tiles[0]
	#return result

#need research
#func _map_DOTTED_STRONG(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	#var result = {}
	#if tiles.size() < 2: return result
	#
	#for y in range(height):
		#for x in range(width):
			#if shape_grid[y][x] != 0:
				#if (x - 1) % 3 == 0 and (y - 2) % 6 == 0:
					#result[Vector2i(x, y)] = tiles[1]
				#else:
					#result[Vector2i(x, y)] = tiles[0]
	#return result

#endregion
