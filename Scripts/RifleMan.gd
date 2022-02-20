extends RigidBody2D

enum {
	HUNT,
	DEFEND
}

var _targets = []
var _time_attack = 31
var _target = null
var _on_player = false
var _hit_time = 30
var _food = 0
var _mode = DEFEND

func _ready() -> void:
	$NpcMoviment.set_ray_size(4)
	set_friction(1.0)
	set_linear_damp(2)

func _drop_food() -> void:
	_food = 0

func take_damage(damage: int) ->  void:
	$LifeSystem.take_damage(damage)

func _stop() -> void:
	$NpcMoviment.stop_moviment()

func _on_NpcMoviment_on_positon() -> void:
	pass

func _on_View_body_entered(body: Object) -> void:
	if body.is_in_group("Player"):
		if _mode == DEFEND:
			return
		if _food > 0:
			_on_player = true
			_stop()
			$Wait_player.start()
			return

func _on_View_body_exited(body: Object) -> void:
	if body.is_in_group("Player"):
		_on_player = false

func _on_Wait_player_timeout() -> void:
	if _on_player:
		_drop_food()

func _on_LifeSystem_dead() -> void:
	queue_free()
