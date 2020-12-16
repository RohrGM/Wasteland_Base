extends Node2D

onready var nav : Navigation2D = get_parent().get_parent().get_parent()
var speed : int = 30

var end_pos = Vector2()
var path = []

signal in_position()

func _ready() -> void:
	set_physics_process(false)
	
func _physics_process(delta : float) -> void:
	if path.size() > 0:
		move_along_path(delta * speed)
	else:
		emit_signal("in_position")
		set_physics_process(false)
	
func start(pos: Vector2, speed_move : int = 30) -> void:
	speed = speed_move
	end_pos = pos
	get_parent().travel_anim("Run")
	_update_navigation_path()
	set_physics_process(true)
	
func _update_navigation_path() -> void:
	path = nav.get_simple_path(get_parent().position, end_pos)
	path.remove(0)

func move_along_path(distance : float) -> void:
	
	var last_point : Vector2 = get_parent().position
	var input_vector : Vector2 = Vector2.ZERO
	
	input_vector.x = path[0].x - last_point.x
	input_vector.y = path[0].y - last_point.y
	
	get_parent().update_anim_tree(input_vector.normalized())
	while path.size():
		var distance_between_points = last_point.distance_to(path[0])

		if distance <= distance_between_points:
			get_parent().position = last_point.linear_interpolate(path[0], distance / distance_between_points)
			return
		distance -= distance_between_points
		last_point = path[0]
		path.remove(0)

	get_parent().position = last_point
	set_physics_process(false)
	emit_signal("in_position")
	
