extends YSort
export var level : int = 0
export var type : String = "b"

func _ready():
	set_process_unhandled_input(false)
	$Icon.hide()
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("interact"):
		interact()
		
func interact() -> void:
	$Icon.hide()
	get_parent().build_barricade(level, type, position)
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)
		$Icon.show()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
		$Icon.hide()
