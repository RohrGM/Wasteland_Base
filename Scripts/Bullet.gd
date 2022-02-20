extends Node

var valid: bool = true

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_entered(body):
	if valid and body.is_in_group("Enemy"):
		valid = false
		queue_free()
		body.take_damage(10)
