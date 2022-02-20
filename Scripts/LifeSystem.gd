extends Node2D

onready var bar_life = $BarLife
var life: int = 100

signal dead()
signal life_in_75()
signal life_in_50()
signal life_in_25()

func _ready() -> void:
	if is_instance_valid(bar_life):
		bar_life.max_value = life
		bar_life.value = life

func _update_gui_life() -> void:
	if is_instance_valid(bar_life):
		bar_life.value = life

func take_damage(damage: int) -> void:
	life -= damage
	if life <= 0:
		life = 0
		emit_signal("dead")
	
	if life < (life * .25):
		emit_signal("life_in_25")
	elif life < (life * .5):
		emit_signal("life_in_50")
	elif life < (life * .75):
		emit_signal("life_in_75")
		
	_update_gui_life()
	
func is_alive() -> bool:
	return true if life > 0 else false

func set_life(value: int) -> void:
	life = value
	
func get_life() -> int:
	return life
	

	
