extends Sprite

func _ready():
	get_node("/root/World/Gui/TimeControl").connect("new_day", self, "_new_day")
	get_node("/root/World/Gui/TimeControl").connect("night", self, "_night")
	travel_anim("idle")

func fire(value: bool) -> void:
	if value:
		travel_anim("fire")
	else:
		travel_anim("idle")

func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)
	
func _new_day() -> void:
	fire(false)

func _night() -> void:
	fire(true)
