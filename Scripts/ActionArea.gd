extends Area2D

signal action(value)

var type : String = ""

func _ready() -> void:
	set_process_unhandled_input(false)
	
func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("interact"):
		emit_signal("action", type)
		
func get_type() -> String:
	return type
	
func set_type(var value : String) -> void:
	type = value

func _on_Area_body_entered(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)


func _on_Area_body_exited(body) -> void:
	set_process_unhandled_input(false)
