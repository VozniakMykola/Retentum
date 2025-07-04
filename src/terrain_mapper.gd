extends Node
class_name TerrainMapper

func map_terrain(terrain_name: G.TerrainPattern, array: Array[Vector2i]) -> Dictionary:
	match terrain_name:
		G.TerrainPattern.SOLID:
			pass
		G.TerrainPattern.CHECKERED:
			pass
		G.TerrainPattern.DOTTED:
			pass
		G.TerrainPattern.HEARTS:
			pass
		G.TerrainPattern.PLAID:
			pass
		G.TerrainPattern.PATCHY:
			pass
		_:
			pass
	return {} #delete this


func _map_SOLID(size: Vector2i):
	pass
