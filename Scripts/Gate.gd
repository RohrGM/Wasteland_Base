extends StaticBody2D


func _ready() -> void:
	hide()
	$CollisionShape2D.disabled = true
	
func open() -> void:
	get_node("../../../../../Nav").set_gate(global_position, 1)
	travel_anim("open")
	for i in get_tree().get_nodes_in_group("Npc"):
		i.stop_move()
		i.new_action(true)
	
func close() -> void:
	get_node("../../../../../Nav").set_gate(global_position, 0)
	travel_anim("close")
	$Timer.start()
	yield($Timer, "timeout")
	for i in get_tree().get_nodes_in_group("Npc"):
		i.stop_move()
		i.new_action(true)

func start() -> void:
	show()
	open()
	$CollisionShape2D.disabled = false
	get_node("/root/World/Gui/TimeControl").connect("new_day", self, "_new_day")
	get_node("/root/World/Gui/TimeControl").connect("horde", self, "_horde")
	
	
func end() -> void:
	hide()
	$CollisionShape2D.disabled = true
	get_node("/root/World/Gui/TimeControl").disconnect("new_day", self, "_new_day")
	get_node("/root/World/Gui/TimeControl").disconnect("horde", self, "_horde")

func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)
	
func _horde() -> void:
	close()
func _new_day() -> void:
	open()
