extends TextureRect

func ballon_text(txt : String, t : int = 3) -> void:
	show()
	$txt.text = txt
	$Timer.wait_time = t
	$Timer.start()

func _on_Timer_timeout():
	hide()
