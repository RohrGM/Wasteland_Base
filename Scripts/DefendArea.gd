extends Position2D

var _gate = null

func defend_position() -> void:
	var gates = get_tree().get_nodes_in_group("Gate")
