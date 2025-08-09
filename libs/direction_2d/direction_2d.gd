extends Resource
class_name Direction2D

# Main
const UP: Vector2i = Vector2i.UP
const DOWN: Vector2i = Vector2i.DOWN
const LEFT: Vector2i = Vector2i.LEFT
const RIGHT: Vector2i = Vector2i.RIGHT
# Diagonal
const UP_LEFT: Vector2i = Vector2i.UP + Vector2i.LEFT
const UP_RIGHT: Vector2i = Vector2i.UP + Vector2i.RIGHT
const DOWN_LEFT: Vector2i = Vector2i.DOWN + Vector2i.LEFT
const DOWN_RIGHT: Vector2i = Vector2i.DOWN + Vector2i.RIGHT
# Special
const ZERO: Vector2i = Vector2i(0, 0)

const DIRECTION_NAMES: Dictionary = {
	UP: "UP",
	DOWN: "DOWN",
	LEFT: "LEFT",
	RIGHT: "RIGHT",
	UP_LEFT: "UP_LEFT",
	UP_RIGHT: "UP_RIGHT",
	DOWN_LEFT: "DOWN_LEFT",
	DOWN_RIGHT: "DOWN_RIGHT",
	ZERO: "ZERO"
}

static func get_direction_name(dir: Vector2i) -> String:
	return DIRECTION_NAMES.get(dir, "INCORRECT")

#Groups
const MAIN_DIRECTIONS: Array[Vector2i] = [UP, RIGHT, DOWN, LEFT]
const DIAGONAL_DIRECTIONS: Array[Vector2i] = [UP_LEFT, UP_RIGHT, DOWN_RIGHT, DOWN_LEFT]
const ALL_DIRECTIONS: Array[Vector2i] = [UP, UP_RIGHT, RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, LEFT, UP_LEFT]
const _ZERO_ARRAY: Array[Vector2i] = [ZERO]
const ALL_DIRECTIONS_AND_ZERO: Array[Vector2i] = ALL_DIRECTIONS + _ZERO_ARRAY

#region Getters
static func get_random_main() -> Vector2i:
	return MAIN_DIRECTIONS[randi() % MAIN_DIRECTIONS.size()]

static func get_random_diagonal() -> Vector2i:
	return DIAGONAL_DIRECTIONS[randi() % DIAGONAL_DIRECTIONS.size()]

static func get_random() -> Vector2i:
	return ALL_DIRECTIONS[randi() % ALL_DIRECTIONS.size()]

static func get_random_including_zero() -> Vector2i:
	return ALL_DIRECTIONS_AND_ZERO[randi() % ALL_DIRECTIONS_AND_ZERO.size()]
#endregion

#region Bools
static func is_main_direction(dir: Vector2i) -> bool:
	return dir in MAIN_DIRECTIONS

static func is_diagonal_direction(dir: Vector2i) -> bool:
	return dir in DIAGONAL_DIRECTIONS
#endregion

#region Other
#not tested
static func get_opposite(dir: Vector2i) -> Vector2i:
	return -dir

static func get_rotated(dir: Vector2i, steps: int = 1) -> Vector2i:
	if dir == ZERO or not (dir in ALL_DIRECTIONS):
		return dir
	
	var current_index = ALL_DIRECTIONS.find(dir)
	var new_index = (current_index + steps) % ALL_DIRECTIONS.size()
	
	if new_index < 0:
		new_index += ALL_DIRECTIONS.size()
	
	return ALL_DIRECTIONS[new_index]

static func direction_to_degrees(dir: Vector2i) -> float:
	if dir == ZERO:
		return 0.0
	
	var vec = Vector2(dir.x, dir.y).normalized()
	var angle_rad = vec.angle_to(Vector2.RIGHT)
	var angle_deg = rad_to_deg(angle_rad)
	
	if angle_deg < 0:
		angle_deg += 360.0
	
	return angle_deg
#endregion
