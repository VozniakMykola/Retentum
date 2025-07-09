extends Node
class_name TerrainMapper

func map_terrain(terrain_name: G.TerrainPattern, palette: Array, shape_grid: Array) -> Dictionary:
	var result = {}
	var height = shape_grid.size()
	if height == 0: return result
	var width = shape_grid[0].size()
	var pattern_tiles = []
	print("_terrain_", G.TerrainPattern.keys()[terrain_name])
	match terrain_name:
		G.TerrainPattern.SOLID:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_SOLID(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.CHECKERED:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_CHECKERED(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.DOTTED:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_DOTTED(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.HEARTS:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_HEARTS(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.PLAID:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_PLAID(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.PATCHY:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_PATCHY(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.ARCHIPELAGO:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_ARCHIPELAGO(pattern_tiles, shape_grid, width, height)
		G.TerrainPattern.ZEBRA_V:
			var zebra_size = randi_range(1, 3)
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_ZEBRA_V(pattern_tiles, shape_grid, width, height, zebra_size)
		G.TerrainPattern.ZEBRA_H:
			var zebra_size = randi_range(1, 3)
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_ZEBRA_H(pattern_tiles, shape_grid, width, height, zebra_size)
		G.TerrainPattern.NOISE:
			var palette_size = palette.size()
			var random_tile_count = randi_range(2, palette_size)
			pattern_tiles = _get_tiles_for_pattern(palette, random_tile_count)
			return _map_NOISE(pattern_tiles, shape_grid, width, height)
		_:
			pattern_tiles = _get_tiles_for_pattern(palette, SHAPE_ELEMENT_COUNT[terrain_name])
			return _map_SOLID(pattern_tiles, shape_grid, width, height)

const SHAPE_ELEMENT_COUNT: Dictionary = {
	G.TerrainPattern.SOLID: 1,
	G.TerrainPattern.CHECKERED: 2,
	G.TerrainPattern.DOTTED: 2,
	G.TerrainPattern.HEARTS: 2,
	G.TerrainPattern.PLAID: 3,
	G.TerrainPattern.PATCHY: 3,
	G.TerrainPattern.NOISE: -1,
	G.TerrainPattern.ZEBRA_V: 2,
	G.TerrainPattern.ZEBRA_H: 2,
	G.TerrainPattern.ARCHIPELAGO: 2,
}


#approved
func _get_tiles_for_pattern(palette: Array, required_count: int) -> Array:
	if palette.size() == 0:
		return []
	var tiles = []
	if palette.size() < required_count:
		tiles = palette.duplicate()
		while tiles.size() < required_count:
			tiles.append(palette[randi() % palette.size()])
	else:
		var indices = range(palette.size())
		indices.shuffle()
		for i in range(required_count):
			tiles.append(palette[indices[i]])
	return tiles

#approved
func _map_SOLID(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.SOLID]: 
		return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				result[Vector2i(x, y)] = tiles[0]
	return result

#approved
func _map_NOISE(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.is_empty(): return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var random_index = randi() % tiles.size() #cr: randi_range(0, tiles.size() - 1)
				result[Vector2i(x, y)] = tiles[random_index]
	return result

#approved
func _map_CHECKERED(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.CHECKERED]: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var index = y % 2
				result[Vector2i(x, y)] = tiles[index]
	return result

#approved
func _map_PLAID(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.PLAID]: return result
	
	var max_dim = maxi(width, height)
	var interval = range(-max_dim, max_dim + 1)
	var count = interval.size() / 3
	interval.shuffle()
	
	var random_coords = interval.slice(0, count)
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var x_ego = x * 2 + (1 if int(y) % 2 == 1 else 0)
				if  (x_ego + y) in random_coords or (x_ego - y) in random_coords:
					result[Vector2i(x, y)] = tiles[1]
				else:
					result[Vector2i(x, y)] = tiles[0]
	return result

#approved
func _map_DOTTED(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.DOTTED]: return result
	
	var used_cords: Array[Vector2i]
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				if !used_cords.has(Vector2i(x,y)):
					result[Vector2i(x, y)] = tiles[0]
				if (x - 1) % 3 == 0 and (y - 2) % 6 == 0:
					var new_x = x + randi_range(-1, 0)
					var new_y = y + randi_range(-1, 1)
					if new_x >= 0 and new_x < width and new_y >= 0 and new_y < height:
						if shape_grid[new_y][new_x] != 0:
							used_cords.append(Vector2i(new_x,new_y))
							result[Vector2i(new_x, new_y)] = tiles[1]
	return result


func _map_HEARTS(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.HEARTS]: return result
	
	var used_cords: Array[Vector2i]
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				if !used_cords.has(Vector2i(x,y)):
					result[Vector2i(x, y)] = tiles[0]
				if (x - 1) % 6 == 0 and (y - 2) % 9 == 0:
					var new_x = x + randi_range(-1, 0)
					var new_y = y + randi_range(-1, 1)
					if shape_grid[new_y][new_x] != 0:
						used_cords.append(Vector2i(new_x,new_y))
						result[Vector2i(new_x, new_y)] = tiles[1]
					if new_x % 2 == 1 && shape_grid[new_y-1][new_x-1] != 0:
						used_cords.append(Vector2i(new_x - 1, new_y - 1))
						result[Vector2i(new_x - 1, new_y - 1)] = tiles[1]
					elif shape_grid[new_y-1][new_x] != 0:
						used_cords.append(Vector2i(new_x, new_y - 1))
						result[Vector2i(new_x, new_y - 1)] = tiles[1]
					if shape_grid[new_y-1][new_x+1] != 0:
						used_cords.append(Vector2i(new_x + 1, new_y - 1))
						result[Vector2i(new_x + 1, new_y - 1)] = tiles[1]
				
	return result

# PATCHY: клаптиковий випадковий візерунок
func _map_PATCHY(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() == 0: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				#var random_index = rng.randi_range(0, tiles.size() - 1)
				#result[Vector2i(x, y)] = tiles[random_index]
				pass
	return result



















#NOT IMPLEMENTED ----------------------------------------------------------------------------

#approved
func _map_ARCHIPELAGO(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.ARCHIPELAGO]: return result
	
	var interval = range(-max(width, height), max(width, height) + 1)
	var count = interval.size() / 4
	interval.shuffle()
	var random_coords = interval.slice(0, count)
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				if (x + y) in random_coords or (x - y) in random_coords:
					result[Vector2i(x, y)] = tiles[0]
				else:
					result[Vector2i(x, y)] = tiles[1]
	return result

#approved
func _map_ZEBRA_V(tiles: Array, shape_grid: Array, width: int, height: int, zebra_size = 1) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.ZEBRA_V]: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var index = (x / zebra_size) % tiles.size()
				result[Vector2i(x, y)] = tiles[index]
	return result

#approved
func _map_ZEBRA_H(tiles: Array, shape_grid: Array, width: int, height: int, zebra_size = 1) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.ZEBRA_H]: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var index = (y / (zebra_size * 2)) % tiles.size()
				result[Vector2i(x, y)] = tiles[index]
	return result



#NOT ADDED ----------------------------------------------------------------------------
func _map_QUINCUNX(tiles: Array, shape_grid: Array, width: int, height: int):
	pass
#need research
func _map_PLAID_3X(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < SHAPE_ELEMENT_COUNT[G.TerrainPattern.PLAID]: return result
	
	var interval = range(-max(width, height), max(width, height) + 1)
	var count = interval.size() / 3
	interval.shuffle()
	var random_coords = interval.slice(0, count)
	var tiles_trimmed = tiles.slice(1)
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				var x_ego = x * 2 + (1 if int(y) % 2 == 1 else 0)
				if  (x_ego + y) in random_coords:
					var tile_index = random_coords.find(x_ego + y) % tiles_trimmed.size()
					result[Vector2i(x, y)] = tiles_trimmed[tile_index]
				elif (x_ego - y) in random_coords:
					var tile_index = random_coords.find(x_ego + y) % tiles_trimmed.size()
					result[Vector2i(x, y)] = tiles_trimmed[tile_index]
				else:
					result[Vector2i(x, y)] = tiles[0]
	return result
#not sure
func _map_DOTTED_STRONG(tiles: Array, shape_grid: Array, width: int, height: int) -> Dictionary:
	var result = {}
	if tiles.size() < 2: return result
	
	for y in range(height):
		for x in range(width):
			if shape_grid[y][x] != 0:
				if (x - 1) % 3 == 0 and (y - 2) % 6 == 0:
					result[Vector2i(x, y)] = tiles[1]
				else:
					result[Vector2i(x, y)] = tiles[0]
	return result
