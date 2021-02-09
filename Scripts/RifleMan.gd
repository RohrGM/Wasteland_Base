extends KinematicBody2D

onready var m : PackedScene = preload("res://PackedScene/MoveAt.tscn")
onready var pt : PackedScene = preload("res://PackedScene/Point.tscn")
onready var fd : PackedScene = preload("res://PackedScene/Food.tscn")

enum{
	HUNT,
	DEFEND
}

var home_pos : Vector2 = Vector2.ZERO
var mv : Node2D = null
var alive : bool = true
var preys : Array = []
var food : int = 0
var mode : int = HUNT
var target : KinematicBody2D = null

#BASIC FUNCTIONS##################################################################################################################################
func _ready() -> void:
	home_pos = Vector2(-6, -10)
	set_physics_process(false)
	travel_anim("Idle")
	if get_node("../../Gui/TimeControl").get_hour() >= 8 and get_node("../../Gui/TimeControl").get_hour() < 22:
		set_mode(HUNT)
	else:
		set_mode(DEFEND)

	get_node("../../Gui/TimeControl").connect("new_day", self, "_new_day")
	get_node("../../Gui/TimeControl").connect("horde", self, "_night")

func set_home(pos : Vector2) -> void:
	home_pos = pos
	
func set_mode(md : int) -> void:
	if md == HUNT:
		set_home(get_parent().get_hunt_area())
	mode = md
	new_action()
	
func take_damage(_value : int = 1) -> void:
	pass

func dead() -> void:
	pass
	
func shot() -> void:
	set_physics_process(false)
	target.dead()
	preys.erase(target)
	target = null
#	if current_targuet != null and current_targuet.alive:
#
#		current_targuet.dead()
#		var rifle_man : Array = get_tree().get_nodes_in_group("Rifle_man")
#		for i in rifle_man:
#			if current_targuet in i.enemys:
#				i.enemys.erase(current_targuet)

func engage() -> void:
	if target != null:
		stop_move()
		set_anim_direction(target.position)
		
		travel_anim("Aim")
		
func more_enemys() -> void:
	if preys.size() > 0:
		target = preys[0]
		engage()
	else:
		new_action(true)

#MOVE FUNCTIONS##################################################################################################################################
func move_at(pos : Vector2, anim : String) -> void:
	var speed = 20
	if anim == "Run":
		speed = 30
				
	stop_move()
	mv = m.instance()
	add_child(mv)
	mv.start(get_parent().get_parent().get_closest_point(pos), speed, anim)
	mv.connect("in_position", self, "_on_MoveAt_in_position")
	
func stop_move() -> void:
	if mv != null:
		travel_anim("Idle")
		mv.queue_free()
		
func sort_direction() -> Vector2:
	var new_direction : Vector2 = Vector2(rand_range(0,1), rand_range(0,1))
	return new_direction
		
func sort_pos(pos : Vector2) -> Vector2:
	pos.x += rand_range(-50, 50)
	pos.y += rand_range(-50, 50)

	return pos

func new_action(var move : bool = false) -> void:
	match mode:
		HUNT:
			randomize()
			var sort_ac : int = randi()%3

			if sort_ac == 1:
				var new_pos : Vector2 = sort_pos(position)
				if position.distance_to(home_pos) > 90:
					new_pos = sort_pos(home_pos)
				else:
					while new_pos.distance_to(home_pos) > 100:
						new_pos = sort_pos(position)

				move_at(new_pos, "Walk")

			else:
				update_anim_tree(sort_direction())
				$Timer.wait_time = rand_range(5, 20)
				$Timer.start()
			
		DEFEND:
			pass


#ANIM FUNCTIONS###################################################################################################################################
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)

func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)
	$AnimationTree.set("parameters/Aim/blend_position", vector)
	
func set_anim_direction(pos : Vector2) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = pos.x - position.x
	input_vector.y = position.y - pos.y 
	update_anim_tree(input_vector.normalized())
	
#HUNT FUNCTIONS##################################################################################################################################


#DEFEND FUNCTIONS##################################################################################################################################
#SIGNAL FUNCTIONS##################################################################################################################################
func _on_Timer_timeout():
	if target == null:
		new_action()
	
func _on_MoveAt_in_position() -> void:
	travel_anim("Idle")
	match mode:
		HUNT:
			if preys.size() == 0:
				$Timer.wait_time = rand_range(1, 5)
				$Timer.start()
				
func _on_View_body_entered(body):
	match mode:
		HUNT:
			if body.is_in_group("Prey"):
				if !body in preys:
					preys.append(body)
					if preys.size() == 1:
						target = preys[0]
						engage()

#var in_player : bool = false
#var current_targuet : KinematicBody2D = null
#

#

#

#func go_to_prey():
#	move_at(prey_closer().position)
#

#
#func hunt() -> void:
#	home_pos = get_node("../HuntAreas").get_child(0).position
#	move_at(sort_pos(home_pos))
#
#func defend() -> void:
#	home_pos = get_node("../DefendAreas").get_child(0).position
#	move_at(sort_pos(home_pos))
#
#
#func engage(var targuet: KinematicBody2D) -> void:
#	$Timer.stop()
#	current_targuet = targuet
#	if current_targuet != null:
#		var direction : Vector2 = Vector2.ZERO
#		direction.x = current_targuet.position.x - position.x
#		direction.y = current_targuet.position.y - position.y
#		stop_move()
#		update_anim_tree(direction.normalized())
#		travel_anim("Shot")
#
#func more_enemys() -> void:
#	if enemys.size() > 0:
#			engage(enemy_closer(enemys))
#	elif preys.size() > 0:
#		go_to_prey()
#	else:
#		new_action(true)
#

#
#func enemy_closer(var ene : Array) -> KinematicBody2D:
#	var distance : float = position.distance_to(ene[0].position)
#	var targuet : KinematicBody2D = ene[0]
#
#	for i in ene:
#		if position.distance_to(i.position) < distance:
#			distance = position.distance_to(i.position)
#			targuet = i
#	return targuet
#
#func drop_food(var value : int) -> void:
#	for i in range(value):
#		var food : RigidBody2D = fd.instance()
#		get_parent().call_deferred("add_child", food)
#		food.position = position + Vector2(0, -20)
#		$Food.start()
#
#		yield($Food, "timeout")
#
#	new_action(true)
#
#
#func _on_Timer_timeout() -> void:
#	new_action()
#
#func _on_MoveAt_in_position() -> void:
#
#	travel_anim("Idle")
#	if enemys.size() == 0 and preys.size() == 0:
#		$Timer.wait_time = rand_range(1, 5)
#		$Timer.start()
#
#func _on_View_body_entered(body) -> void:
#	if body.is_in_group("Animal") or body.is_in_group("Enemy"):
#		enemys.append(body)
#		if enemys.size() == 1:
#			engage(enemys[0])
#
#func _on_View_body_exited(body) -> void:
#	pass
#
#func _on_View_area_entered(area):
#	if area.is_in_group("Prey") and area.get_free():
#		area.set_free(false)
#		preys.append(area)
#		if enemys.size() == 0:
#			go_to_prey()
#
#func _on_TakeFood_area_entered(area):
#	if area.is_in_group("Prey"):
#		if area in preys:
#			preys.erase(area)
#			area.queue_free()
#			food += 1
#
#			if enemys.size() > 0:
#				engage(enemy_closer(enemys))
#			elif preys.size() > 0:
#				go_to_prey()
#			else:
#				new_action()
#
#
#func _on_TakeFood_body_entered(body):
#	if body.is_in_group("Player"):
#		in_player = true
#		stop_move()
#		$InPlayer.wait_time = 1
#		$InPlayer.start()
#
#func _on_TakeFood_body_exited(body):
#	if body.is_in_group("Player"):
#		in_player = true
#
#func _on_InPlayer_timeout():
#	if in_player:
#		drop_food(food)
#		food = 0
#	else:
#		new_action(true)






