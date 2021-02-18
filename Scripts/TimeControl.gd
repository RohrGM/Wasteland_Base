extends Control

onready var light_canvas : CanvasModulate = get_node("/root/World/CanvasModulate")

var day : int = 1
var hour : int = 8
var minute : int = 1
var time : float = .0
var night : bool = false

export(Gradient) var light_day
export(Gradient) var light_night

signal new_day()
signal horde()
signal hour()
signal night()

func _ready() -> void:
	set_physics_process(false)
	update()
	
func _physics_process(delta):
	time += .001
	if night:
		light_canvas.color = light_night.interpolate(time)
	else:
		light_canvas.color = light_day.interpolate(time)
		
	if time > 1:
		time = 0
		set_physics_process(false)

func update() -> void:
	$Day.text = "Dia " + String(day)
	$Clock.text = "%02d : %02d" % [hour, minute]

func get_day() -> int:
	return day
	
func get_hour() -> int:
	return hour

func _on_Timer_timeout() -> void:
	minute += 1
	
	if minute >= 60:
		minute = 0
		hour += 1
		emit_signal("hour")
		
		if hour == 24:
			hour = 0
		elif hour == 8:
			day += 1
			emit_signal("new_day")
			night = false
			set_physics_process(true)
		elif hour == 23:
			emit_signal("horde")
		elif hour == 22:
			emit_signal("night")
			set_physics_process(true)
			night = true
	update()

