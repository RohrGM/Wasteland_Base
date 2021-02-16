extends KinematicBody2D

onready var m : PackedScene = preload("res://PackedScene/MoveAt.tscn")
onready var pt : PackedScene = preload("res://PackedScene/Point.tscn")
onready var fd : PackedScene = preload("res://PackedScene/Food.tscn")
onready var bullet : PackedScene = preload("res://PackedScene/Bullet.tscn")

enum{
	HUNT,
	DEFEND
}

var home_pos : Vector2 = Vector2.ZERO
var mv : Node2D = null
var alive : bool = true
var preys : Array = []
var enemys : Array = []
var food : int = 0
var mode : int = HUNT
var in_player : bool = false
var target : KinematicBody2D = null
var tg_pos : Vector2 = Vector2.ZERO

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
	get_node("../../Gui/TimeControl").connect("night", self, "_night")
	
func _physics_process(delta) -> void:
	if target != null:
		$Aim.look_at(target.position)
		set_anim_direction(target.position)

func set_home(pos : Vector2) -> void:
	home_pos = pos
	
func set_mode(md : int) -> void:
	if md == HUNT:
		set_home(get_parent().get_hunt_area())
	else:
		preys = []
		target = null
		set_home(get_parent().get_defend_area())
	mode = md
	new_action(true)
	
func take_damage(_value : int = 1) -> void:
	pass

func dead() -> void:
	pass
	
func shot() -> void:
	set_physics_process(false)
	$Particles2D.emitting = true
	randomize()
	if randi()% 10 > 5:
		spaw_b(50)
	else:
		spaw_b(0)

func spaw_b( value : int = 0) -> void:
	var bullet_inst : RigidBody2D = bullet.instance()
	bullet_inst.position = $Aim/Spaw.global_position
	bullet_inst.rotation_degrees = $Aim.rotation_degrees 
	bullet_inst.apply_impulse(Vector2(), Vector2(300, 0).rotated($Aim.rotation + value))
	get_parent().add_child(bullet_inst)

func engage() -> void:
	if target != null:
		
		stop_move()
		$Timer.stop()
		if position.distance_to(target.position) < 130:
			set_physics_process(true)
			stop_move()
			$Timer.stop()
			tg_pos = target.position
			travel_anim("Aim")
		else:
			move_at(target.position, "Run")
	else:
		match mode:
			HUNT:
				var tg : KinematicBody2D = preys[0]
				var distance : float = position.distance_to(preys[0].position)
				
				for i in preys:
					if position.distance_to(i.position) < distance:
						distance = position.distance_to(i.position)
						tg = i
				target = tg
			DEFEND:
				var tg : KinematicBody2D = enemys[0]
				var distance : float = position.distance_to(enemys[0].position)
				
				for i in enemys:
					if position.distance_to(i.position) < distance:
						distance = position.distance_to(i.position)
						tg = i
				target = tg
		engage()
		
func more_enemys() -> void:
	if preys.size() > 0:
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
	match mode:
		HUNT:
			pos.x += rand_range(-150, 150)
			pos.y += rand_range(-150, 150)
		DEFEND:
			pos.x += rand_range(-50, 50)
			pos.y += rand_range(-50, 50)

	return pos

func patrol_area(move : bool) -> void:
	
	var range_area : int = 80
	
	match mode:
		HUNT:
			range_area = 250
		DEFEND:
			range_area = 80
	randomize()
	var sort_ac : int = randi()%3
	
	if move:
		sort_ac = 1

	if sort_ac == 1:
		var new_pos : Vector2 = sort_pos(position)
		if position.distance_to(home_pos) > range_area:
			new_pos = sort_pos(home_pos)
		else:
			while new_pos.distance_to(home_pos) > range_area:
				new_pos = sort_pos(position)

		move_at(new_pos, "Walk")

	else:
		update_anim_tree(sort_direction())
		$Timer.wait_time = rand_range(5, 20)
		$Timer.start()
		
func new_action(var move : bool = false) -> void:
	match mode:
		HUNT:
			if preys.size() > 0:
				engage()
			else:
				patrol_area(move)
			
		DEFEND:
			if enemys.size() > 0:
				engage()
			else:
				patrol_area(move)


#ANIM FUNCTIONS###################################################################################################################################
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)

func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)
	$AnimationTree.set("parameters/Aim/blend_position", vector)
	
func set_anim_direction(pos : Vector2) -> void:
	update_anim_tree((position + Vector2(0, -5)).direction_to(pos))
	
#HUNT FUNCTIONS##################################################################################################################################
func drop_food() -> void:
	for i in range(food):
		var food : RigidBody2D = fd.instance()
		get_parent().call_deferred("add_child", food)
		food.position = position + Vector2(0, -20)
		$Food.start()

		yield($Food, "timeout")
	food = 0

	new_action(true)

#DEFEND FUNCTIONS##################################################################################################################################
#SIGNAL FUNCTIONS##################################################################################################################################
func _target_dead(tg : KinematicBody2D) -> void:
	match mode:
		HUNT:
			if tg in preys:
				preys.erase(tg)
				if target == tg:
					target = null
					food += 1
					new_action()
		DEFEND:
			if tg in enemys:
				enemys.erase(tg)
				if target == tg:
					target = null
					new_action()
					
	var rifle_man : Array = get_tree().get_nodes_in_group("Rifle_man")
	for i in rifle_man:
		if tg in i.preys:
			i.preys.erase(tg)
			if tg == target:
				target = null

func _on_Timer_timeout() -> void:
	if target == null:
		new_action()
	
func _on_MoveAt_in_position() -> void:
	match mode:
		HUNT:
			if preys.size() == 0:
				$Timer.wait_time = rand_range(1, 5)
				$Timer.start()
				travel_anim("Idle")
			else:
				if target != null:
					travel_anim("Aim")
		DEFEND:
			if enemys.size() == 0:
				$Timer.wait_time = rand_range(1, 5)
				$Timer.start()
				travel_anim("Idle")
			else:
				if target != null:
					travel_anim("Aim")
							
func _on_View_body_entered(body) -> void:
	match mode:
		HUNT:
			if body.is_in_group("Prey"):
				if !body in preys:
					preys.append(body)
					body.connect("dead", self, "_target_dead")
					if preys.size() == 1:
						engage()
				else:
					if body == target:
						engage()
		DEFEND:
			if body.is_in_group("Enemy"):
				print("Inimigo!")
				if !body in enemys:
					enemys.append(body)
					body.connect("dead", self, "_target_dead")
					if enemys.size() == 1:
						engage()
				else:
					if body == target:
						engage()

func _on_InteractArea_body_entered(body) -> void:
	if body.is_in_group("Player"):
		if target == null:
			in_player = true
			stop_move()
			$Timer.stop()
			$InPlayer.start()
			
func _on_InteractArea_body_exited(body) -> void:
	if body.is_in_group("Player"):
		in_player = false

func _on_InPlayer_timeout() -> void:
	if in_player:
		drop_food()
	else:
		new_action(true)
		
func _night() -> void:
	set_mode(DEFEND)
	
func _new_day() -> void:
	set_mode(HUNT)
		
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












