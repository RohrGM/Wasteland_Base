extends StaticBody2D


var _life = 100
var _valid = true

func drop_tree():
	$Sprite.scale = Vector2($Sprite.scale.x, .15)

func is_valid():
	return _valid

func is_alive():
	return true if _life > 0 else false

func set_valid(value):
	_valid = value

func take_damage(damage : int):
	_life -= damage
	if _life <= 0:
		drop_tree()
		_valid = false

func get_point():
	return $Position2D.global_position
