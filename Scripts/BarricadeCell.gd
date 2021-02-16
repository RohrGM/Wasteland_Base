extends StaticBody2D
export var type : String = "h"
func _ready() -> void:
	update_anim(0)

func update_anim(value : int) -> void:
	if value == 1:
		get_node("../../../../../../Nav").set_barricade(global_position, type)
	$AnimationTree.set("parameters/Idle/blend_position", value)
