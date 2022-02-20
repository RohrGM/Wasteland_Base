extends KinematicBody2D

onready var bullet = preload("res://PackgeScene/Bullet.tscn")
onready var astar = get_tree().get_root().get_node("World/Astar")
onready var moviment =  $AstarMoviment
onready var life_system = $LifeSystem
onready var home_pos = Vector2(558, 256)
onready var last_map_pos: Vector2 = astar.world_to_map(position)

var enemys: Array = []
var _current_attack_pos: int = 0


func _ready():
	set_physics_process(true)
	
func _physics_process(_delta):
	_check_enemy_list()
	
	if enemys.size() > 0:
		enemys.sort_custom(self, "_sort_ascending")
		
		var target = enemys[0]
		$Arm.look_at(target.position)
		_evasive_moviment(target.position)
		
	else:
		$ShotTime.stop()
		
func take_damage(damage: int) -> void:
	life_system.take_damage(damage)
		
func is_alive() -> bool:
	return life_system.is_alive()
		
func get_attack_pos() -> Vector2:
	var attack_points = $AttackPoints.get_children()
	
	_current_attack_pos += 1
	if _current_attack_pos >= attack_points.size():
		_current_attack_pos = 0
	
	return attack_points[_current_attack_pos].global_position
		
	
func _sort_ascending(a, b) -> bool:
	if a.position.distance_squared_to(position) < b.position.distance_squared_to(position):
		return true
	return false
	
func _evasive_moviment(pos: Vector2) -> void:
	var my_cell = astar.world_to_map(position)
	
	var map_pos = astar.world_to_map(pos)
	var new_cell = my_cell + (my_cell.direction_to(map_pos) * -1)
	new_cell = Vector2(round(new_cell.x), round(new_cell.y))
	
	if my_cell.distance_to(map_pos) < 3:
		moviment.move(astar.map_to_world(new_cell), 30)
		
func _check_enemy_list() -> void:
	for e in enemys.duplicate():
		if is_instance_valid(e):
			continue
		else:
			enemys.erase(e)
		
func _spaw_bullet( value : int = 0) -> void:
	var bullet_inst : RigidBody2D = bullet.instance()
	bullet_inst.position = $Arm/Spaw.global_position
	bullet_inst.rotation_degrees = $Arm.rotation_degrees 
	bullet_inst.apply_impulse(Vector2(), Vector2(500, 0).rotated($Arm.rotation + value))
	get_parent().add_child(bullet_inst)
	
func move_at():
	if moviment.move(Vector2(home_pos.x + rand_range(-100, 100), home_pos.y + rand_range(-100, 100)), 30):
		return
	else:
		$Timer.start()

func _on_AstarMoviment_on_position():
	pass
		
func _on_Timer_timeout():
	move_at()

func _on_View_body_entered(body):
	if body.is_in_group("Enemy"):
		$ShotTime.start()
		enemys.append(body)
		set_physics_process(true)

func _on_ShotTime_timeout():
	_spaw_bullet()


func _on_LifeSystem_dead():
	queue_free()
