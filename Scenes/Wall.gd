extends YSort

onready var astar = get_tree().get_root().get_node("World/Astar")

export(String, "north", "south", "west", "east") var map_area

var _index = 0

func _ready() -> void:
	for wall in $Walls.get_children():
		astar.set_cell_status(false, wall.global_position)

func get_map_area() -> String:
	return map_area

func is_alive() -> bool:
	return $LifeSystem.is_alive()
	
func get_pos_attack() ->  Vector2:
	var pos = $Walls.get_child(_index).global_position
	_index += 1
	
	if _index > $Walls.get_child_count() - 1:
		_index = 0
		
	match map_area:
		"south": 
			pos += Vector2(0, 15)
		
	return pos

func take_damage(damage: int) -> void:
	$LifeSystem.take_damage(damage)

func _on_LifeSystem_dead():
	for wall in $Walls.get_children():
		astar.set_cell_status(true, wall.global_position)
	queue_free()
