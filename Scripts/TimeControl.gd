extends Control

var day : int = 1
var hour : int = 8
var minute : int = 1

signal new_day()
signal horde()

func _ready() -> void:
	update()

func update() -> void:
	$Day.text = "Dia " + String(day)
	$Clock.text = "%02d : %02d" % [hour, minute]

func get_day() -> int:
	return day

func _on_Timer_timeout() -> void:
	minute += 1
	
	if minute >= 60:
		minute = 0
		hour += 1
		
		if hour == 24:
			hour = 0
		elif hour == 8:
			day += 1
			emit_signal("new_day")
		elif hour == 22:
			emit_signal("horde")
	update()

