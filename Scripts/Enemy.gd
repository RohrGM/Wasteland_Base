extends KinematicBody2D

onready var astar = get_tree().get_root().get_node("World/Astar")
onready var world = get_tree().get_root().get_node("World")
onready var moviment =  get_node("AstarMoviment")
onready var attack_pos = Vector2(558, 256)
onready var _life_system = $LifeSystem
onready var enemys : Array = get_tree().get_nodes_in_group("Ally")
onready var spaw = "south"
var target = null
var last_target_post = Vector2.ZERO
var _time = 31

func _physics_process(_delta):
	_time += 1
	var gate = world.get_gate(spaw)
	if is_instance_valid(gate) and gate.is_alive():
		target = gate
	else:
		_check_enemy_list()
		if enemys.size() > 0:
			enemys.sort_custom(self, "_sort_ascending")
			target = enemys[0]
			
	if is_instance_valid(target):
		if position.distance_to(target.position) < 20:
			$Arm.look_at(target.position)
			_attack()
		else:
			if last_target_post != target.position:
				last_target_post = target.position
				var pos = target.get_attack_pos()
				if _time > 30:
					_time = 0
					moviment.move(pos, 26)

func take_damage(damage: int) -> void:
	_life_system.take_damage(damage)

func _hit():
	if is_instance_valid(target) and position.distance_to(target.position) < 20:
		target.take_damage(20)
	
func _check_enemy_list() -> void:
	for e in enemys.duplicate():
		if is_instance_valid(e):
			continue
		else:
			enemys.erase(e)

func _attack() -> void:
	$AnimationPlayer.play("attack")

func _sort_ascending(a, b) -> bool:
	if a.position.distance_squared_to(position) < b.position.distance_squared_to(position):
		return true
	return false

func _on_AstarMoviment_on_position():
	$Timer.start()

func _on_Timer_timeout():
	pass

func _on_LifeSystem_dead():
	queue_free()
