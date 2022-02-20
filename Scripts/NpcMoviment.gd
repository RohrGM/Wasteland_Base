extends Node2D

onready var body = get_parent()
onready var astar = get_tree().get_root().get_node("World/Astar")

const ARRIVE_DISTANCE = 1
const MAX_THRUST = 90

var max_speed= rand_range(15, 30)
var _point_distance = rand_range(50, 150)

var _path = []
var _target_point_world: Vector2 = Vector2()

signal on_positon()

func astar_move_at(end_pos: Vector2) -> void:
	_update_path(end_pos)

func stop_moviment() -> void:
	_path = []

func _move_on_obstacles(state: Physics2DDirectBodyState, linear_velocity: Vector2, target_position: Vector2):
	var delta = state.get_step()
	var closest_collision = null
	var my_pos = body.global_position
	var distance_to_target = my_pos.distance_to(target_position)
	var vector_to_target = (target_position - my_pos).normalized()

	$Rays.rotation += delta * 11 * PI

	for ray in $Rays.get_children():
		if ray.is_colliding():
			var collision_point = ray.get_collision_point() - my_pos
			if closest_collision == null:
				closest_collision = collision_point
			if collision_point.length() < closest_collision.length():
				closest_collision = collision_point

	if closest_collision:
		var normal = -closest_collision.normalized()
		var dodge_direction = 1
		if randf() < 0.5:
			dodge_direction = -1
		linear_velocity += normal * MAX_THRUST * 2 * delta
		linear_velocity += normal.rotated(PI/2 * dodge_direction) * MAX_THRUST * delta
		
	if distance_to_target > 5:
		linear_velocity += vector_to_target * MAX_THRUST * delta
	else:
		_on_position()

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	return linear_velocity

func direction_moviment(state: Physics2DDirectBodyState, linear_velocity: Vector2, target_position: Vector2) -> Vector2:
	linear_velocity = _move_on_obstacles(state, linear_velocity, target_position)
	return linear_velocity

func astar_moviment(state: Physics2DDirectBodyState, linear_velocity: Vector2) -> Vector2:
	if _path.size() > 0:
		var target_position = _path[0]
		linear_velocity = _move_on_obstacles(state, linear_velocity, target_position)

	else:
		linear_velocity = Vector2.ZERO

	return linear_velocity
	
func _on_position() -> void:
	if _path.size() > 0:
		_path.remove(0)
		if !(_path.size() > 0):
			emit_signal("on_positon")

func is_on_path() -> bool:
	return true if _path.size() > 0 else false

func _update_path(end_pos: Vector2) -> void:
	var my_pos = body.global_position
	_path = astar.get_astar_path(my_pos, end_pos)
	if _path.size() > 0:
		_target_point_world = _path[0]
	
func set_ray_size(size: int) -> void:
	$Rays/R1.cast_to.y = size
	$Rays/R2.cast_to.y = -size
	$Rays/R3.cast_to.x = size
	$Rays/R4.cast_to.x = -size  
