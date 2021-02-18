extends YSort

var max_life : int = 100
var life : int = 0

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
		for i in get_tree().get_nodes_in_group("Npc"):
			if !i.is_in_group("Axe_man"):
				i.new_action(true)
