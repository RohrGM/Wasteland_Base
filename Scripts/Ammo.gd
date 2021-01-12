extends TextureRect

onready var sh : PackedScene = preload("res://PackedScene/Shell.tscn")

var ammo : int = 0
var size : int = 7

func add(var value : int) -> void:
	ammo += value
	$Label.text = String(ammo)
	
func remove(var value : int) -> int:
	if ammo - value >= 0:
		ammo -= value
	else:
		value = ammo
		ammo = 0
		
	$Label.text = String(ammo)
	return value
		
func remove_shell() -> void:
	if have_ammo():
		$HBox.get_child(0).queue_free()
		
func reload() -> void:
	ammo += $HBox.get_children().size()
	
	if have_ammo():
		for i in $HBox.get_children():
			i.queue_free()
		
	for i in range(remove(size)):
		var shell : TextureRect = sh.instance()
		$HBox.add_child(shell)
		
func have_ammo() -> bool:
	if $HBox.get_children().size() > 0:
		return true
	return false
