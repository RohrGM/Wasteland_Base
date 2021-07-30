extends YSort

var max_life : int = 100
var life : int = 0

func take_damage( value : int = 1) -> void:
	life =- value
	
	if life % 20 == 0:
		for i in $YSort.get_children():
			i.update_anim(life/20)
	if life == 0:
		if has_node("Gate"):
			$Gate.end()
		for i in $YSort.get_children():
			i.update_anim(0)

func hit() -> void:
	life += 10	
	if life == max_life:
		get_parent().get_parent().get_parent().build_end(self)
		for i in $YSort.get_children():
			i.update_anim(5)
	if life % 20 == 0:
		for i in $YSort.get_children():
			i.update_anim(life/20)
	if life == 20:
		if has_node("Gate"):
			$Gate.start()
		for i in get_tree().get_nodes_in_group("Npc"):
			if !i.is_in_group("Axe_man"):
				i.stop_move()
				i.new_action(true)
				
