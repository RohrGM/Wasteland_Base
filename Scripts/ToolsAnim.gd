extends Sprite

onready var ax : PackedScene = preload("res://PackedScene/Tools.tscn")

var type : int 

func end() -> void:
	var toolsAxe : Area2D = ax.instance()
	get_parent().call_deferred("add_child", toolsAxe)
	toolsAxe.position = position
	toolsAxe.set_type(type)
	queue_free()

