extends Node
class_name ShapeMapper

func create_shape(shape_name: G.ShapePattern, size: Vector2i) -> Array:
	match shape_name:
		G.ShapePattern.RECTANGLE:
			return _create_RECTANGLE(size)
		G.ShapePattern.DIAMOND:
			return _create_DIAMOND(size)
		_:
			pass
	return []

func _create_RECTANGLE(size: Vector2i):
	pass

func _create_DIAMOND(size: Vector2i):
	pass
