extends TileMap

onready var barricade = get_node("../YSort/Barricade")

func set_barricade() -> void:
	
	var usedCell1 = barricade.get_used_cells_by_id(0)
	var usedCell2 = barricade.get_used_cells_by_id(1)
	
	for i in usedCell1:
		set_cellv(i, 3)
	
	for i in usedCell2:
		set_cellv(i, 2)
