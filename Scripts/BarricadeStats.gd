extends YSort

var max_life : int = 100
var life : int = 0

func hit() -> void:
	life += 1
	
	if life == max_life:
		get_parent().get_parent().get_parent().build_end(self)
	for i in $YSort.get_children():
		i.update_anim(life)
