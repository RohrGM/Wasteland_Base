extends Area2D

export var item_name : String = "fork"

func _ready() -> void:
	set_process_unhandled_input(false)
	
func _unhandled_input(_event):
	if Input.is_action_just_pressed("interact"):
		get_node("../Farm").add_item(item_name)
		queue_free()

func _on_Fork_body_entered(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)


func _on_Fork_body_exited(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
