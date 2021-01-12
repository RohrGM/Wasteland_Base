extends TextureRect

var cam_d : Vector2 = Vector2(.5, .5)
var cam_n : Vector2 = Vector2(1, 1)

signal end_dialogue()

func start(dg : Dictionary, agent : KinematicBody2D) -> void:
		show()
		
		agent.player(false)
		agent.set_cam(cam_d)
		agent.set_canvas(false)
		
		for i in dg:
			show_dg(dg[i])
			yield($Button, "pressed")
		hide()
		
		agent.player(true)
		agent.set_cam(cam_n)
		agent.set_canvas(true)
		
		emit_signal("end_dialogue")

func show_dg(t : String) -> void:
	$txt.text = t
