extends Area2D

func _on_MotherEvent_body_entered(body):
	if body.is_in_group("Player"):
		get_parent()._end_dialogue()
