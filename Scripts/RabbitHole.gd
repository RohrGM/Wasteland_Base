extends StaticBody2D

onready var rb : PackedScene = preload("res://PackedScene/Rabbit.tscn")

var time : int = 6

func _ready():
	spaw()

func spaw() -> void:
	var rabbit : KinematicBody2D = rb.instance()
	get_parent().get_parent().call_deferred("add_child", rabbit)
	rabbit.position = position + Vector2(0, -10)
	rabbit.connect("dead", self, "_rabbit_dead")
	
func _rabbit_dead(rb) -> void:
	get_node("../../../Gui/TimeControl").connect("hour", self, "_hour_passed")
	
func _hour_passed() -> void:
	time -= 1
	if time == 0:
		get_node("../../../Gui/TimeControl").disconnect("hour", self, "_hour_passed")
		time = 6
		spaw()
	
	
