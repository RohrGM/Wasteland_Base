extends Area2D

enum{
	AXE,
	FORK
}

var type : int
var tools : int = 0

signal new_tool(value)

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
	
func remove_tools() -> void:
	if tools > 0:
		tools -= 1
		set_anim(tools)
		if tools == 0:
			$Timer.stop()
		
func get_tools() -> int:
	return tools

func interact() -> void:
	if tools < 6:
		tools += 1
		set_anim(tools)
		emit_signal("new_tool", position)
		$Timer.start()

func _on_ToolsAxe_body_entered(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)
		
	if body.is_in_group("NPC"):
		remove_tools()
		body.up_tool()

func _on_ToolsAxe_body_exited(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)


func _on_Timer_timeout():
	emit_signal("new_tool", position)
