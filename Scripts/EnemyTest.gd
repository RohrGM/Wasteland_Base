extends RigidBody2D

onready var astar = get_tree().get_root().get_node("World/Astar")
onready var _alvo_position = get_tree().get_root().get_node("World/Alvo").global_position

export(String, "north", "south", "west", "east") var map_area

var _targets = []
var _potential_targets = []
var _gate = null
var _gate_attack_pos = Vector2()

var _attack_time = 30

func _ready() -> void:
	set_friction(1.0)
	set_linear_damp(2)
	
	$NpcMoviment.connect("on_positon", self, "_on_NpcMoviment_on_positon")
	$NpcMoviment.set_ray_size(4)
	
	$View.connect("body_entered", self, "_on_View_body_entered")
	$View.connect("body_exited", self, "_on_View_body_exited")
	
	var gates = get_tree().get_nodes_in_group("Gate")
	
	for gate in gates:
		if gate.get_map_area() == map_area:
			_gate = gate
			break
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	_alvo_position += Vector2(rng.randi_range(0, 3) * 16, rng.randi_range(0, 3) * 16)

func _process(_delta) -> void:
	if _potential_targets.size() > 0:
		for target in _potential_targets.duplicate():
			$View/Ray.look_at(target.global_position)
			if $View/Ray.is_colliding():
				if $View/Ray.get_collider().is_in_group("Ally"):
					_targets.append(target)
					_potential_targets.erase(target)

func _attack(target: Object) -> void:
	if target.has_method("take_damage"):
		target.take_damage(15)
		
func get_target() -> Object:
	var sort = Sort.new(global_position)
	_targets.sort_custom(sort, "_sort_ascending")
	return _targets[0]

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if _targets.size() > 0:
		var target_pos = get_target().global_position
		if global_position.distance_to(target_pos) < 20:
			if _attack_time > 30:
				_attack(_targets[0])
				_attack_time = 0
			else:
				_attack_time += 1
		
		$View/Ray.look_at(target_pos)
		if $View/Ray.is_colliding():
			var collider = $View/Ray.get_collider()
			if is_instance_valid(collider) and collider.is_in_group("Ally"):
				if $NpcMoviment.is_on_path():
					$NpcMoviment.stop_moviment()
				linear_velocity = $NpcMoviment.direction_moviment(state, linear_velocity, target_pos)
			else:
				if $NpcMoviment.is_on_path():
					linear_velocity = $NpcMoviment.astar_moviment(state, linear_velocity)
				else:
					$NpcMoviment.astar_move_at(target_pos)
		return
		
	if is_instance_valid(_gate) and _gate.is_alive():
		if global_position.distance_to(_gate_attack_pos) < 10:
			if _attack_time > 30:
				_attack(_gate)
				_attack_time = 0
			else:
				_attack_time += 1
			return
			
		if $NpcMoviment.is_on_path():
			linear_velocity = $NpcMoviment.astar_moviment(state, linear_velocity)
		else:
			_gate_attack_pos = _gate.get_pos_attack()
			$NpcMoviment.astar_move_at(_gate_attack_pos)
		return
	
	if $NpcMoviment.is_on_path():
		linear_velocity = $NpcMoviment.astar_moviment(state, linear_velocity)
	else:
		$NpcMoviment.astar_move_at(_alvo_position)
	return

func _on_NpcMoviment_on_positon() -> void:
	pass
	
func _on_View_body_entered(body: Object) -> void:
	if body.is_in_group("Ally"):
		if not body in _potential_targets:
			_potential_targets.append(body)
	
func _on_View_body_exited(body: Object) -> void:
	if body.is_in_group("Ally"):
		if body in _targets:
			_targets.erase(body)
