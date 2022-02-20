extends KinematicBody2D

onready var _world = get_tree().get_root().get_node("World")
onready var _life_system = $LifeSystem

var _current_attack_pos: int = 0

export(String) var gate_name = "south"

func _ready() -> void:
	_world.set_gate(gate_name, self)
	_life_system.set_life(500)
	
func is_alive() -> bool:
	return _life_system.is_alive()

func get_attack_pos() -> Vector2:
	var attack_points = $AttackPoints.get_children()
	
	_current_attack_pos += 1
	if _current_attack_pos >= attack_points.size():
		_current_attack_pos = 0
	
	return attack_points[_current_attack_pos].global_position
	
func take_damage(damage: int) -> void:
	_life_system.take_damage(damage)


func _on_LifeSystem_dead():
	queue_free()
