extends TileMap

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color.white

# The Tilemap node doesn't have clear bounds so we're defining the map's limits here.
export(Vector2) var map_size = Vector2.ONE * 16

# The path start and end variables use setter methods.
# You can find them at the bottom of the script.
var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []
# You can only create an AStar node from code, not from the Scene tab.
onready var astar_node = AStar2D.new()
# get_used_cells_by_id is a method from the TileMap node.
# Here the id 0 corresponds to the grey tile, the obstacles.
onready var obstacles = []
onready var _half_cell_size = cell_size / 2

func _ready():
	obstacles = get_used_cells_by_id(0)
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells_diagonal(walkable_cells_list)

func is_free(cell: Vector2) -> bool:
	return false if cell in obstacles else true

# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles.
func astar_add_walkable_cells(obstacle_list = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in obstacle_list:
				continue

			points_array.append(point)
			# The AStar class references points with indices.
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point.
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s.
			astar_node.add_point(point_index, Vector2(point.x, point.y))
	return points_array

# Once you added all points to the AStar node, you've got to connect them.
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like.
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...

			
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce.
		# We connect the current point with it.
		var points_relative = PoolVector2Array([
			point + Vector2.RIGHT,
			point + Vector2.LEFT,
			point + Vector2.DOWN,
			point + Vector2.UP,
		])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A.
			# If you set this value to false, it becomes a one-way path.
			# As we loop through all points we can set it to false.
			astar_node.connect_points(point_index, point_relative_index, false)

# This is a variation of the method above.
# It connects cells horizontally, vertically AND diagonally.
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)
				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)

func calculate_point_index(point: Vector2) -> int:
	return point.x + map_size.x * point.y

func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y

func get_astar_path(world_start, world_end):
	path_start_position = world_to_map(world_start)
	path_end_position = world_to_map(world_end)
	
	if self.path_end_position == Vector2.ZERO:
		path_end_position = world_to_map(world_end)
	
	_recalculate_path()

		
	var path_world = []
	for point in _point_path:
		randomize()
		var point_world = map_to_world(Vector2(point.x, point.y)) + Vector2(cell_size.x / 2, cell_size.y /2)
		path_world.append(point_world)
		
	return path_world

func set_point_state(map_pos: Vector2, state: bool) -> void:
	astar_node.set_point_disabled(calculate_point_index(map_pos), !state)
	set_cellv(map_pos, 0 if !state == false else -1)
	
func _recalculate_path():
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and
	# end points' indices as input.
	
	#ignore-error: get_point_path
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	update()

# Setters for the start and end path values.
func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	path_end_position = value
	if path_start_position != value:
		_recalculate_path()

func set_cell_status(status: bool, pos: Vector2) -> void:
	var cell = world_to_map(pos)
	var index = calculate_point_index(cell)
	astar_node.set_point_disabled(index, !status)
	set_cellv(cell, 0 if !status else 1)
