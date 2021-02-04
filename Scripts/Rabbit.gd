extends KinematicBody2D

onready var m : PackedScene = preload("res://PackedScene/MoveAt.tscn")
onready var pt : PackedScene = preload("res://PackedScene/Point.tscn")
onready var rd : PackedScene = preload("res://PackedScene/RabbitDead.tscn")

var home_pos : Vector2 = Vector2.ZERO
var mv : Node2D = null
var target_pos : Vector2 = Vector2.ZERO
var alive : bool = true

signal dead()

func _ready() -> void:
	home_pos = position
	set_physics_process(false)
	travel_anim("Idle")
	
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)
	
func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)

func new_action() -> void:	
	randomize()
	var sort_ac : int = randi()%4
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
		
func move_at(pos : Vector2, speed : int = 12, anim : String = "Walk") -> void:
	stop_move()
	mv = m.instance()
	add_child(mv)
	mv.start(pos, speed, anim)
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
	
func take_damage(_value : int = 1) -> void:
	pass
	
func dead() -> void:
	var rabbit : Area2D = rd.instance()
	get_parent().call_deferred("add_child", rabbit)
	rabbit.position = position
	emit_signal("dead")
	queue_free()

func _on_Timer_timeout() -> void:
	new_action()
	
func _on_MoveAt_in_position() -> void:
	travel_anim("Idle")
	$Timer.wait_time = rand_range(1, 5)
	$Timer.start()
		
func _on_View_body_entered(body) -> void:
	if body.is_in_group("Player") or body.is_in_group("NPC"):
		move_at(run_away(body.position), 40, "Run")

func _on_View_body_exited(body) -> void:
	pass
