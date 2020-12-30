extends RigidBody2D


func _on_Area2D_area_entered(area) -> void:
	if area.name == "HitBox":
		area.get_parent().dead()
		queue_free()


func _on_Timer_timeout():
	queue_free()


func _on_Area2D_body_entered(body):
	queue_free()
