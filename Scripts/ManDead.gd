extends Area2D

func _ready() -> void:
	set_process_unhandled_input(false)
	
func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("interact"):
		$AnimationPlayer.current_animation = "end"

func _on_ManDead_body_entered(body):
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)


func _on_ManDead_body_exited(body):
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
