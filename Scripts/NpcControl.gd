extends YSort

var buildings : Array = []

#RIFLEMAN FUNCTIONS###############################################################################
func get_hunt_area() -> Vector2:
	return $HuntAreas/Position2D.position
	
func get_defend_area() -> Vector2:
	return $DefendAreas/Position2D.position

#AXEMAN FUNCTIONS###############################################################################
func add_building(bd) -> void:
	if !bd in buildings:
		buildings.append(bd)
		if buildings.size() == 1:
			for i in get_tree().get_nodes_in_group("Axe_man"):
				i.set_mode(1)

func have_building() -> bool:
	if buildings.size() > 0:
		return true
	return false
	
func build_end(bd) -> void:
	remove_building(bd)
	for i in get_tree().get_nodes_in_group("Axe_man"):
		i.end_build()
	
func remove_building(bd) -> void:
	if bd in buildings:
		buildings.erase(bd)
		
func get_building():
	return buildings[0]
	
func get_tree_objective():
	var trees : Array = []
	
	for tree in get_tree().get_nodes_in_group("Tree"):
		if tree.get_free() and tree.position.distance_to($WoodAreas.get_child(0).position) < 200:
			return tree
	
	return null
