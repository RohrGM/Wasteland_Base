extends RigidBody2D


func _ready():
	randomize()
	$Timer.wait_time = rand_range(.5, 1)
	apply_impulse(Vector2(), Vector2(rand_range(30, 40),rand_range(0, 50)).rotated(-90))

func _on_Timer_timeout():
	set_deferred("mode", 1)
