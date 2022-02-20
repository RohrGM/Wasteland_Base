extends RigidBody2D

onready var point = get_tree().get_root().get_node("World/Alvo")
onready var bullet = preload("res://PackgeScene/Bullet.tscn")
onready var body = self

enum {
	MOVING,
	IDLE
}

var MAX_SPEED = 150
var MAX_THRUST = 50

var _moviment_state = MOVING

var _targets = []

var _enemy_distance = 80
var _point_distance = rand_range(40, 80)
var _time_attack = 30

func _ready():
	set_friction(1.0)
	set_linear_damp(2)
	_targets.append(point)

func _physics_process(_delta):
	
	if _targets.size() < 1:
		return
	
	if !_targets[0].is_in_group("Enemy"):
		return
		
	_time_attack += 1
	var _target = _targets[0]
	
	if _time_attack > 30:
		_time_attack = 0
		_spaw_bullet()
		
	$Arm.look_at(_target.global_position)

func take_damage(damage: int) -> void:
	$LifeSystem.take_damage(damage)

func _spaw_bullet(value : int = 0) -> void:
	var bullet_inst : RigidBody2D = bullet.instance()
	bullet_inst.position = $Arm/Spaw.global_position
	bullet_inst.rotation_degrees = $Arm.rotation_degrees 
	bullet_inst.apply_impulse(Vector2(), Vector2(500, 0).rotated($Arm.rotation + value))
	get_parent().add_child(bullet_inst)

func _sort_ascending(a, b) -> bool:
	if a.position.distance_squared_to(position) < b.position.distance_squared_to(position):
		return true
	return false

func _check_targets():
	for target in _targets.duplicate():
		if is_instance_valid(target):
			continue
		_targets.erase(target)
		
	_targets.sort_custom(self, "_sort_ascending")

func _integrate_forces(state):
	
	_check_targets()
		
	if _moviment_state == IDLE:
		return
		
	if _targets.size() < 1:
		return
	
	var target = _targets[0]
	
	var delta = state.get_step()
	# Check nearby objects with raycast
	var closest_collision = null
	$Rays.rotation += delta * 11 * PI
	for ray in $Rays.get_children():
		if ray.is_colliding():
			var collision_point = ray.get_collision_point() - global_position
			if closest_collision == null:
				closest_collision = collision_point
			if collision_point.length() < closest_collision.length():
				closest_collision = collision_point

	# Dodge
	if closest_collision:
		var normal = -closest_collision.normalized()
		var dodge_direction = 1
		if randf() < 0.5:
			dodge_direction = -1
		linear_velocity += normal * MAX_THRUST * 2 * delta
		linear_velocity += normal.rotated(PI/2 * dodge_direction) * MAX_THRUST * delta

	# Steer towards player
	var distance_to_player = global_position.distance_to(target.global_position)
	var vector_to_player = (target.global_position - global_position).normalized()

	if target.is_in_group("Enemy"):
		if distance_to_player > _enemy_distance :
			# Move towards player
			linear_velocity += vector_to_player * MAX_THRUST * delta
		else:
			# Move away from player
			linear_velocity += -vector_to_player * MAX_THRUST * delta
	else:
		if distance_to_player > _point_distance :
			# Move towards player
			linear_velocity += vector_to_player * MAX_THRUST * delta
		

	# Clamp max speed
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED

func _on_View_body_entered(body):
	if body.is_in_group("Enemy"):
		_moviment_state = MOVING
		_targets.append(body)

func _on_LifeSystem_dead():
	queue_free()
