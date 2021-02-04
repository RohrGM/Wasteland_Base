extends Area2D

var free : bool = true
var life : int = 30
var time : int = 4

func hit(var agent : KinematicBody2D) -> void:
	life -= 1
	if life <= 0:
		travel_anim("St3")
		get_node("../../../Gui/TimeControl").connect("new_day", self, "_new_day")
		agent.tree_down()
		
	else:
		travel_anim("Hit")
	
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)

func get_free() -> bool:
	return free
	
func set_free(var value : bool) -> void:
	free = value
	
func _new_day() -> void:
	time -= 1
	if time == 2:
		travel_anim("St2")
	elif time == 0:
		time = 4
		travel_anim("St1")
		set_free(true)
		get_node("../../../Gui/TimeControl").disconnect("new_day", self, "_new_day")
