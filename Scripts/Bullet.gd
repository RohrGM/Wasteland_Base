extends RigidBody2D

func _on_Timer_timeout() -> void:
	queue_free()

func _on_Area2D_body_entered(_body) -> void:
	queue_free()

func _on_Area2D_area_entered(area) -> void:
	if area.get_parent().has_method("take_damage"):
		pass
#		area.get_parent().take_damage()
#		queue_free()
