extends Area2D

const MOTION_SPEED = 20 # Pixels/second.

func _ready() -> void:
	set_physics_process(false)

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y *= 0.57735056839 # tan(30 degrees).
	motion = motion.normalized() * MOTION_SPEED
	motion.x *= .05
	#warning-ignore:return_value_discarded
	$Body.move_and_slide(motion)

func _on_Mother_body_entered(body):
	if body.is_in_group("Player"):
		set_physics_process(true)


func _on_Mother_body_exited(body):
	if body.is_in_group("Player"):
		set_physics_process(false)
