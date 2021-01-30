extends Area2D

var free : bool = true
var life : int = 10

func _ready():
	pass # Replace with function body.


func hit(var agent : KinematicBody2D) -> void:
	life -= 1
	if life <= 0:
		travel_anim("St3")
		agent.tree_down()
		
	else:
		travel_anim("Hit")
	
	
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)

func get_free() -> bool:
	return free
	
func set_free(var value : bool) -> void:
	free = value
