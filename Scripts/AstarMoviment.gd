extends Node

onready var astar = get_tree().get_root().get_node("World/Astar")
onready var body = get_parent()

const ARRIVE_DISTANCE = 1

var speed : int

var _path = []
var _target_point_world: Vector2 = Vector2()
var _target_position: Vector2 = Vector2()
var _direction: Vector2 = Vector2()
var _velocity:Vector2 = Vector2()
var _last_point: Vector2 = Vector2.ZERO

signal on_position()
signal new_direction(value)

func _ready() -> void:
	set_physics_process(false)

func _physics_process(_delta) -> void:
	var _arrived_to_next_point = _move_to(_target_point_world)
	if _arrived_to_next_point:
		_path.remove(0)
		
		if len(_path) == 0:
			emit_signal("on_position")
			set_physics_process(false)
			return
		
		_target_point_world = _path[0]
		
func move(target_position: Vector2, new_speed: int) -> bool:
	speed = new_speed
	_target_position = target_position

	if _update_path():
		set_physics_process(true)
		return true
	print ("posição invalida")
	return false
		


func _move_to(world_position):
	var desired_velocity = (world_position - body.position).normalized() * speed
	var new_dir = Vector2(-1 if desired_velocity.normalized().x < 0 else 1, -1 if desired_velocity.normalized().y < 0 else 1)
	
	if new_dir != _direction:
		_direction = new_dir
		emit_signal("new_direction", _direction)
	
	var steering = desired_velocity - _velocity
	_velocity += steering 
	_velocity = body.move_and_slide(_velocity, Vector2(0,0), false, 30, 1.0 )
	body.position = Vector2(stepify(body.position.x, .5), stepify(body.position.y, .5))
	return body.position.distance_to(world_position) < ARRIVE_DISTANCE
	
func _update_path() -> bool:
	_path = astar.get_astar_path(body.position, _target_position)
	if _path.size() > 1:
		_target_point_world = _path[1]
		return true
	return false
