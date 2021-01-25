extends Area2D

enum{
	AXE,
	FORK,
	RIFLE
}

onready var fm : PackedScene = preload("res://PackedScene/farmNPC.tscn")
onready var rm : PackedScene = preload("res://PackedScene/RifleMan.tscn")

var tools : int = 0
var type : int
var npcs : Array = []

func _ready() -> void:
	set_process_unhandled_input(false)
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("interact"):
		interact()
		
func set_type(var ty : int) -> void:
	type = ty
	match(type):
		AXE:
			$Sprite.texture = load("res://Assets/tools_axe.png")
		FORK:
			$Sprite.texture = load("res://Assets/tools_fork.png")
		RIFLE:
			$Sprite.texture = load("res://Assets/tools_rifle.png")

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
		$Timer.start()
		check_no_tool()
		
		if npcs.size() > 0:
			up_npc(npcs[0])
			
func check_no_tool() -> void:
	var npc_no_tool = get_tree().get_nodes_in_group("No_tool")
	if npc_no_tool.size() > 0:
		for i in npc_no_tool:
			i.go_tool(position)

func up_npc(npc) -> void:
	remove_tools()
	match(type):
		AXE:
			npc.up_tool(fm)
		FORK:
			npc.up_tool(fm)
		RIFLE:
			npc.up_tool(rm)

func _on_ToolsAxe_body_entered(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(true)
		
	if body.is_in_group("No_tool"):
		npcs.append(body)
		if get_tools() > 0:
			up_npc(body)

func _on_ToolsAxe_body_exited(body) -> void:
	if body.is_in_group("Player"):
		set_process_unhandled_input(false)
	if body.is_in_group("No_tool"):
			npcs.erase(body)

func _on_Timer_timeout():
	check_no_tool()
