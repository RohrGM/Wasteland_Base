extends Area2D

onready var sm : PackedScene = preload("res://PackedScene/StrawMan.tscn")

func _ready() -> void:
	set_process_unhandled_input(false)

func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("interact"):
		interact()
		
func interact() -> void:
	var straw : StaticBody2D = sm.instance()
	get_parent().call_deferred("add_child", straw)
	straw.position = position
	queue_free()


func _on_Field_body_entered(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)


func _on_Field_body_exited(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
