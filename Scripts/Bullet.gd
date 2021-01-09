extends RigidBody2D

func _on_Area2D_area_entered(area) -> void:
	if area.name == "HitBox" and area.get_parent().alive:
		queue_free()
		area.get_parent().dead()
		

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_entered(body):
	queue_free()
