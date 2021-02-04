extends StaticBody2D

func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)
