extends Node

class_name Sort

var pos
func _init(p) -> void:
	pos = p

func _sort_ascending(a, b) -> bool:
	if a.global_position.distance_squared_to(pos) < b.global_position.distance_squared_to(pos):
		return true
	return false
