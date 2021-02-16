extends KinematicBody2D

onready var m : PackedScene = preload("res://PackedScene/MoveAt.tscn")
onready var pt : PackedScene = preload("res://PackedScene/Point.tscn")
onready var lg : PackedScene = preload("res://PackedScene/Log.tscn")

enum{
	LUMBERJACK,
	BUILD,
	SURVIVE
}

var home_pos : Vector2 = Vector2.ZERO
var mv : Node2D = null
var alive : bool = true
var wood : int = 0
var in_player : bool = false
var mode : int = LUMBERJACK
var objective = null


#BASIC FUNCTIONS##################################################################################################################################

func _ready() -> void:
	home_pos = Vector2(-6, -10)
	set_physics_process(false)
	travel_anim("Idle")
	if get_node("../../Gui/TimeControl").get_hour() >= 8 and get_node("../../Gui/TimeControl").get_hour() < 20:
		if get_parent().have_building():
			set_mode(BUILD)
		else:
			set_mode(LUMBERJACK)
	else:
		set_mode(SURVIVE)

	get_node("../../Gui/TimeControl").connect("new_day", self, "_new_day")
	get_node("../../Gui/TimeControl").connect("horde", self, "_night")
	
func set_home(pos : Vector2) -> void:
	home_pos = pos
	
func set_mode(md : int) -> void:
	if mode == LUMBERJACK and objective != null:
		objective.set_free(true)
		objective = null
	mode = md
	new_action()
	
func take_damage(_value : int = 1) -> void:
	pass

func dead() -> void:
	pass
			
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


func new_action() -> void:
	match mode:
		LUMBERJACK:
			if objective == null:
				objective = get_parent().get_tree_objective()
				
			if objective != null:
				objective.set_free(false)
				var direction : float = objective.position.x - position.x
				if direction > 0:
					move_at(objective.position + Vector2(-15, 0), "Walk")
				else:
					move_at(objective.position + Vector2(15, 0), "Walk")
			else:
				home()
		BUILD:
			if get_parent().have_building():
				objective = get_parent().get_building()
				randomize()
				if objective.is_in_group("F"):
					move_at(Vector2(objective.position.x -120 + randi() % 240, objective.position.y + 5), "Run")
				elif objective.is_in_group("B"):
					move_at(Vector2(objective.position.x -120 + randi() % 240, objective.position.y - 5), "Run")
				elif objective.is_in_group("R"):
					move_at(Vector2(objective.position.x - 8, objective.position.y -120 + randi() % 240), "Run")
				else:
					move_at(Vector2(objective.position.x + 8, objective.position.y -120 + randi() % 240), "Run")
		SURVIVE:
			home()
			
func home()-> void:
	if position.distance_to(home_pos) > 90:
		move_at(sort_pos(home_pos), "Run")
	
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


#ANIM FUNCTIONS###################################################################################################################################

func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)

func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Attack/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Build/blend_position", vector)
	
func set_anim_direction(pos : Vector2) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = pos.x - position.x
	update_anim_tree(input_vector)
	
#LUMBERJACK FUNCTIONS##################################################################################################################################

func hit_tree():
	objective.hit(self)
		
func drop_wood() -> void:
	for i in range(wood):
		var wood : RigidBody2D = lg.instance()
		get_parent().call_deferred("add_child", wood)
		wood.position = position + Vector2(0, -20)
		$Wood.start()
		
		yield($Wood, "timeout")
	wood = 0
	new_action()
	
func tree_down() -> void:
	wood += 1
	travel_anim("Idle")
	objective = null
	new_action()
	
#BUILD FUNCTIONS##################################################################################################################################
func build_hit() -> void:
	if objective != null:
		if !objective.is_in_group("Tree"):
			objective.hit()
		
func end_build() -> void:
	objective = null
	if get_parent().have_building():
		set_mode(BUILD)
	else:
		set_mode(LUMBERJACK)
		
#SIGNAL FUNCTIONS##################################################################################################################################
func _on_MoveAt_in_position() -> void:	
	travel_anim("Idle")
	match mode:
		LUMBERJACK:
			
			if objective != null and position.distance_to(objective.position) < 20:
				set_anim_direction(objective.position)
				travel_anim("Attack")
			else:
				new_action()
		BUILD:
			if position.distance_to(objective.position) < 120:
				set_anim_direction(objective.position)
				travel_anim("Build")
			else:
				new_action()
		SURVIVE:
			new_action()

func _new_day() -> void:
	if get_parent().have_building():
		set_mode(BUILD)
	else:
		set_mode(LUMBERJACK)
		
func _night() -> void:
	set_mode(SURVIVE)
	
func _on_InteractArea_body_entered(body):
	if body.is_in_group("Player"):
		stop_move()
		$InPlayer.start()
		in_player = true

func _on_InteractArea_body_exited(body):
	if body.is_in_group("Player"):
		in_player = false

func _on_InPlayer_timeout():
	if in_player:
		drop_wood()
		wood = 0
	else:
		new_action()

func _on_View_body_entered(body):
	if body.is_in_group("Enemy"):
		move_at(run_away(body.position), "Run")











