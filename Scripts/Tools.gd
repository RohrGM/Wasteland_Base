extends Area2D

enum{
	AXE,
	FORK
}

var type : int
var tools : int = 0

func _ready() -> void:
	set_process_unhandled_input(false)
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("interact"):
		interact()
		
func set_type(var ty : int) -> void:
	match(ty):
		AXE:
			$Sprite.texture = load("res://Assets/tools_axe.png")
		FORK:
			$Sprite.texture = load("res://Assets/tools_fork.png")

func set_anim(var value : int) -> void:
	$Sprite.frame = tools
	
func get_tools() -> void:
	if tools > 0:
		tools -= 1
		set_anim(tools)

func interact() -> void:
	if tools < 6:
		tools += 1
		set_anim(tools)

func _on_ToolsAxe_body_entered(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)

func _on_ToolsAxe_body_exited(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
