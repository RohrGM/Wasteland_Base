extends KinematicBody2D

onready var m : PackedScene = preload("res://PackedScene/MoveAt.tscn")
onready var pt : PackedScene = preload("res://PackedScene/Point.tscn")


var home_pos : Vector2 = Vector2.ZERO
var mv : Node2D = null
var alive : bool = true
var enemys : Array = []
var preys : Array = []
var food : int = 0
var current_targuet : KinematicBody2D = null

func _ready() -> void:
	home_pos = Vector2(-6, -10)
	set_physics_process(false)
	travel_anim("Idle")
	if get_node("../../Gui/TimeControl").get_hour() >= 8 and get_node("../../Gui/TimeControl").get_hour() < 22:
		hunt()
	else:
		defend()
	
	get_node("../../Gui/TimeControl").connect("new_day", self, "hunt")
	get_node("../../Gui/TimeControl").connect("horde", self, "defend")
		
func set_home(pos : Vector2) -> void:
	home_pos = pos
	
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)
	
func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)
	$AnimationTree.set("parameters/Aim/blend_position", vector)
	$AnimationTree.set("parameters/Shot/blend_position", vector)

func new_action() -> void:
	randomize()
	var sort_ac : int = randi()%3
	if sort_ac == 1:
		
		var new_pos : Vector2 = sort_pos(position)
		if position.distance_to(home_pos) > 90:
			new_pos = sort_pos(home_pos)
		else:
			while new_pos.distance_to(home_pos) > 100:
				new_pos = sort_pos(position)
				
		move_at(new_pos)
	
	else:
		update_anim_tree(sort_direction())
		$Timer.wait_time = rand_range(5, 20)
		$Timer.start()
		
func move_at(pos : Vector2) -> void:
	stop_move()
	mv = m.instance()
	add_child(mv)
	mv.start(pos, 20, "Walk")
	mv.connect("in_position", self, "_on_MoveAt_in_position")
	
func stop_move() -> void:
	if mv != null:
		mv.queue_free()

func sort_direction() -> Vector2:
	var new_direction : Vector2 = Vector2(rand_range(0,1), rand_range(0,1))
	return new_direction
		
func sort_pos(pos : Vector2) -> Vector2:
	pos.x += rand_range(-50, 50)
	pos.y += rand_range(-50, 50)
	
	return pos

func run_away(pos: Vector2) -> Vector2:
	var new_pos : Vector2 = position
	
	if pos.x - position.x > 0:
		new_pos.x -= rand_range(50,100)
	else:
		new_pos.x += rand_range(50,100)
		
	if pos.y - position.y > 0:
		new_pos.y -= rand_range(50,100)
	else:
		new_pos.y += rand_range(50,100)

	return new_pos
	
func go_to_prey():
	move_at(prey_closer().position)
	
func prey_closer() -> Area2D:
	var distance : float = position.distance_to(preys[0].position)
	var targuet : Area2D = preys[0]
	
	for i in preys:
		if position.distance_to(i.position) < distance:
			distance = position.distance_to(i.position)
			targuet = i
	return targuet
func take_damage(_value : int = 1) -> void:
	pass

func dead() -> void:
	pass
	
func hunt() -> void:
	home_pos = get_node("../HuntAreas").get_child(0).position
	move_at(sort_pos(home_pos))
	
func defend() -> void:
	home_pos = get_node("../DefendAreas").get_child(0).position
	move_at(sort_pos(home_pos))


func engage(var targuet: KinematicBody2D) -> void:
	current_targuet = targuet
	if current_targuet != null:
		var direction : Vector2 = Vector2.ZERO
		direction.x = current_targuet.position.x - position.x
		direction.y = current_targuet.position.y - position.y
		stop_move()
		update_anim_tree(direction.normalized())
		travel_anim("Shot")
	
func more_enemys() -> void:
	if enemys.size() > 0:
		engage(enemy_closer())
	elif preys.size() > 0:
		go_to_prey()
	else:
		new_action()
		
func shot() -> void:
	if current_targuet != null and current_targuet.alive:
		
		current_targuet.dead()
		var rifle_man : Array = get_tree().get_nodes_in_group("Rifle_man")
		for i in rifle_man:
			if current_targuet in i.enemys:
				i.enemys.erase(current_targuet)
		
func enemy_closer() -> KinematicBody2D:
	var distance : float = position.distance_to(enemys[0].position)
	var targuet : KinematicBody2D = enemys[0]
	
	for i in enemys:
		if position.distance_to(i.position) < distance:
			distance = position.distance_to(i.position)
			targuet = i
	return targuet

func _on_Timer_timeout() -> void:
	new_action()
	
func _on_MoveAt_in_position() -> void:
	
	travel_anim("Idle")
	if enemys.size() == 0 and preys.size() == 0:
		$Timer.wait_time = rand_range(1, 5)
		$Timer.start()
		
func _on_View_body_entered(body) -> void:
	if body.is_in_group("Animal") or body.is_in_group("Enemy"):
		enemys.append(body)
		if enemys.size() == 1:
			engage(enemys[0])

func _on_View_body_exited(body) -> void:
	pass

func _on_View_area_entered(area):
	if area.is_in_group("Prey") and area.get_free():
		area.set_free(false)
		preys.append(area)
		if enemys.size() == 0:
			go_to_prey()

func _on_TakeFood_area_entered(area):
	if area.is_in_group("Prey"):
		if area in preys:
			preys.erase(area)
			area.queue_free()
			food += 1
			
			if enemys.size() > 0:
				engage(enemy_closer())
			elif preys.size() > 0:
				go_to_prey()
			else:
				new_action()
