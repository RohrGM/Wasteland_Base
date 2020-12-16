extends Area2D

signal hole(value)

func _ready() -> void:
	set_process_unhandled_input(false)

func _on_Hole_body_entered(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)

func _on_Hole_body_exited(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
