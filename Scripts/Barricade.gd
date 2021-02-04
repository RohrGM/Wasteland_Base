extends YSort

func _ready():
	for i in $Nv1/BarricadeBehind.get_children():
		i.travel_anim("8")
