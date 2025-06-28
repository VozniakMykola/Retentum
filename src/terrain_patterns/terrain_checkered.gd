extends TerrainPattern
class_name TerrainCheckered

func generate() -> Array:
	var field = []
	for x in 8:
		for y in 8:
			field.append(Vector2(x, y))
	return field
