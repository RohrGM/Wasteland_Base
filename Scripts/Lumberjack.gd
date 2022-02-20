extends RigidBody2D

var _targets = []
var _time_attack = 31
var _target = null
var _cut_tree = false
var _on_player = false
var _hit_time = 30

var _trees = []
var _woods = 0

func _ready() -> void:
	$NpcMoviment.set_ray_size(4)
	set_friction(1.0)
	set_linear_damp(2)
	_check_trees()
	_search_tree()

func _search_tree() -> void:
	_check_trees()
	if _trees.size() > 0:
		_target = _trees[0]
		_target.set_valid(false)
		$NpcMoviment.astar_move_at(_target.get_point())

func _add_wood() -> void:
	_woods += 5
	
func _drop_wood() -> void:
	_woods = 0
	print("dropei")

func _physics_process(_delta: float) -> void:
	if _cut_tree and _target:
		if _target.is_alive():
			if _hit_time > 30:
				_target.take_damage(20)
				_hit_time = 0
			_hit_time += 1
			return

		_add_wood()
		_cut_tree = false
		_search_tree()

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	linear_velocity = $NpcMoviment.astar_moviment(state, linear_velocity)

func _check_trees() -> void:
	_trees = get_tree().get_nodes_in_group("Tree")

	for tree in _trees.duplicate():
		if !tree.is_valid() or !tree.is_alive():
			_trees.erase(tree)

	_trees.sort_custom(self, "_sort_ascending")

func take_damage(damage: int) ->  void:
	$LifeSystem.take_damage(damage)

func _stop() -> void:
	if _target:
		_target.set_valid(true)
		$NpcMoviment.stop_moviment()

func _on_NpcMoviment_on_positon() -> void:
	if global_position.distance_to(_target.global_position) < 30:
		_cut_tree = true
		return
	_search_tree()

func _on_View_body_entered(body: Object) -> void:
	if body.is_in_group("Player"):
		if _woods > 0:
			_on_player = true
			_stop()
			$Wait_player.start()
			return
		print("Não tenho wood")

func _on_View_body_exited(body: Object) -> void:
	if body.is_in_group("Player"):
		_on_player = false

func _on_Wait_player_timeout() -> void:
	if _on_player:
		_drop_wood()
	print("seguindo")
	_search_tree()

func _on_LifeSystem_dead():
	queue_free()
