extends TextureRect

signal end_dialogue()

func start(dg : Dictionary) -> void:
		show()
		for i in dg:
			show_dg(dg[i])
			yield($Button, "pressed")
		hide()
		emit_signal("end_dialogue")

func show_dg(t : String) -> void:
	$txt.text = t
