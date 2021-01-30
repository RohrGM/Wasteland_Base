extends YSort

func _ready():
	set_process_unhandled_input(false)
	$Icon.hide()
	
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("interact"):
		interact()
		
func interact() -> void:
	$Icon.hide()
	get_node("../Barricade").position = Vector2.ZERO
	get_node("../../Nav").set_barricade()
	
	for i in get_tree().get_nodes_in_group("BarricadeBase"):
		i.queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)
		$Icon.show()


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
		$Icon.hide()
