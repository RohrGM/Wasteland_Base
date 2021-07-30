extends YSort

onready var behind1 : PackedScene = preload("res://PackedScene/BarricadeBehind.tscn")
onready var forward1 : PackedScene = preload("res://PackedScene/BarricadeForward.tscn")
onready var right1 : PackedScene = preload("res://PackedScene/BarricadeRight.tscn")
onready var left1 : PackedScene = preload("res://PackedScene/BarricadeLeft.tscn")

var nvl1 : bool = true

func build_barricade(var nvl : int , var type : String, pos : Vector2) -> void:
	match nvl:
		1:
			var new : YSort
			
			if type == "b":
				new = behind1.instance()
				$Nv1.call_deferred("add_child", new)
				new.position = pos
				
			elif type == "f":
				new = forward1.instance()
				$Nv1.call_deferred("add_child", new)
				new.position = pos
				
			elif type == "r":
				new = right1.instance()
				$Nv1.call_deferred("add_child", new)
				new.position = pos
				
			elif type == "l":
				new = left1.instance()
				$Nv1.call_deferred("add_child", new)
				new.position = pos
			get_parent().add_building(new)
			
			
			
				
