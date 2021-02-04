extends KinematicBody2D

onready var m : PackedScene = preload("res://PackedScene/MoveAt.tscn")
onready var pt : PackedScene = preload("res://PackedScene/Point.tscn")
onready var lg : PackedScene = preload("res://PackedScene/Log.tscn")


var home_pos : Vector2 = Vector2.ZERO
var mv : Node2D = null
var alive : bool = true
var wood : int = 0
var trees : Array = []
var in_player : bool = false
var current_tree : Area2D = null
var farming : bool = true

func _ready() -> void:
	home_pos = Vector2(-6, -10)
	set_physics_process(false)
	travel_anim("Idle")
	if get_node("../../Gui/TimeControl").get_hour() >= 8 and get_node("../../Gui/TimeControl").get_hour() < 22:
		farm()
	else:
		home()
	
	get_node("../../Gui/TimeControl").connect("new_day", self, "farm")
	get_node("../../Gui/TimeControl").connect("horde", self, "home")
		
func set_home(pos : Vector2) -> void:
	home_pos = pos
	
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)
	
func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Farm/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)


func new_action(var move : bool = false) -> void:
	var sort_ac : int = 1
	
	if !move:
		randomize()
		sort_ac = randi()%3
		
	if current_tree != null:
		farm_wood()
	
	else:
		
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
	
func hit_tree():
	if current_tree != null:
		current_tree.hit(self)
	
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
	
func take_damage(_value : int = 1) -> void:
	pass

func dead() -> void:
	pass
	
func farm() -> void:
	home_pos = get_node("../WoodAreas").get_child(0).position
	move_at(sort_pos(home_pos))
	farming = true
	
func home() -> void:
	home_pos = get_node("../Fireplace").position
	move_at(sort_pos(home_pos))
	
	if current_tree != null:
		current_tree.set_free(true)
	farming = false
	current_tree = null
	trees = []
	
func drop_wood(var value : int) -> void:
	for i in range(value):
		var wood : RigidBody2D = lg.instance()
		get_parent().call_deferred("add_child", wood)
		wood.position = position + Vector2(0, -20)
		$Wood.start()
		
		yield($Wood, "timeout")
	
	new_action(true)
	
func farm_wood() -> void:
	move_at(current_tree.position + Vector2(-20, 0))
	
func tree_down() -> void:
	wood += 1
	travel_anim("Idle")
	trees.erase(current_tree)
	
	
	var axe_man : Array = get_tree().get_nodes_in_group("Axe_man")
	for i in axe_man:
		if current_tree in i.trees:
			i.trees.erase(current_tree)
	
	current_tree = null

	if trees.size() > 0:
		go_to_tree()
	else:
		new_action(true)
	
func go_to_tree() -> void:
	current_tree = closer_tree(trees)
	current_tree.set_free(false)
	var axe_man : Array = get_tree().get_nodes_in_group("Axe_man")
	for i in axe_man:
		if current_tree in i.trees:
			i.trees.erase(current_tree)
	farm_wood()
	
func closer_tree(var list : Array) -> Area2D:
	var distance : float = position.distance_to(list[0].position)
	var targuet : Area2D = list[0]
	
	for i in list:
		if position.distance_to(i.position) < distance:
			distance = position.distance_to(i.position)
			targuet = i
	return targuet
		

func _on_Timer_timeout() -> void:
	new_action()
	
func _on_MoveAt_in_position() -> void:	
	travel_anim("Idle")
	
	if current_tree != null:
		var input_vector : Vector2 = Vector2.ZERO
		input_vector.x = current_tree.position.x - position.x
		input_vector.y = current_tree.position.y - position.y
		update_anim_tree(input_vector)
		travel_anim("Attack")
		
	else:
		$Timer.wait_time = rand_range(1, 5)
		$Timer.start()

func _on_View_body_entered(body) -> void:
	pass

func _on_View_body_exited(body) -> void:
	pass
	
func _on_View_area_entered(area):
	if area.is_in_group("Tree") and area.get_free() and farming:
		trees.append(area)
		if current_tree == null:
			go_to_tree()

func _on_InPlayer_timeout():
	if in_player:
		drop_wood(wood)
		wood = 0
	else:
		new_action(true)


func _on_TakeWood_body_entered(body):
	if body.is_in_group("Player"):
		in_player = true
		stop_move()
		$InPlayer.wait_time = 1
		$InPlayer.start()

func _on_TakeWood_body_exited(body):
	if body.is_in_group("Player"):
		in_player = true

