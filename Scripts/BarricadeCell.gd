extends StaticBody2D
func _ready() -> void:
	update_anim(0)

func update_anim(value : int) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", value)
