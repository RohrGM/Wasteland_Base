extends KinematicBody2D


func _physics_process(delta):
	travel_anim("Aim")
	set_anim_direction(get_global_mouse_position())


func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)

func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)
	$AnimationTree.set("parameters/Aim/blend_position", vector)
	
func set_anim_direction(pos : Vector2) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = pos.x - position.x
	input_vector.y = position.y - pos.y 
	update_anim_tree(input_vector.normalized())
