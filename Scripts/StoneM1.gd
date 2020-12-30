extends RigidBody2D

var target : Vector2 = Vector2.ZERO
		
func start(tg : Vector2) -> void:
	target = tg

func _on_Area2D_area_entered(area) -> void:
	set_deferred("mode", 1)
	$AnimatedSprite.set_deferred("playing", true)
	if area.name == "Point":
		area.queue_free()


func _on_AnimatedSprite_animation_finished():
	queue_free()
