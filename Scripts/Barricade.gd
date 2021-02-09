extends YSort

onready var behind1 : PackedScene = preload("res://PackedScene/BarricadeBehind.tscn")

func build_barricade(var nvl : int , var type : String) -> void:
	match nvl:
		1:
			if type == "b":
				var new : YSort = behind1.instance()
				$Nv1.call_deferred("add_child", new)
				new.position = Vector2(1, 117)
				
				get_parent().add_building(new)
				
