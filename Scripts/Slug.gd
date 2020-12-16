extends KinematicBody2D

var home_pos : Vector2 = Vector2.ZERO
var enemys : Array = []

signal death()

func _ready() -> void:
	home_pos = position
	set_physics_process(false)
	
func _physics_process(_delta):
	if enemys[0].position.distance_to(position) > 20:
		$MoveAt.move(enemys[0].position)
	else:
		attack()
	
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)
	
func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Attack/blend_position", vector)

func new_action() -> void:
	var sort_ac : int = int(rand_range(0, 3))
	
	if sort_ac < 1:
		var new_pos : Vector2 = sort_pos(position)
		if position.distance_to(home_pos) > 90:
			new_pos = sort_pos(home_pos)
		else:
			while new_pos.distance_to(home_pos) > 100:
				new_pos = sort_pos(position)
				
		$MoveAt.move(new_pos)
	
	else:
		update_anim_tree(sort_direction())
		$Timer.wait_time = rand_range(1, 5)
		$Timer.start()
		
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

func attack() -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = enemys[0].position.x - position.x
	input_vector.y = enemys[0].position.y - position.y
	
	update_anim_tree(input_vector.normalized())
	
	travel_anim("Attack")
	
func take_damage(_value : int = 1) -> void:
	dead()

func dead() -> void:
	set_physics_process(false)
	travel_anim("Dead")
	$MoveAt.stop_move()
	$View.monitoring = false
	$HitBox.queue_free()
	$Timer.queue_free()
	$CollisionShape2D.queue_free()
	emit_signal("death")
	set_script(null)

func _on_Timer_timeout() -> void:
	new_action()
	
func _on_MoveAt_in_position() -> void:
	if enemys.size() < 1:
		travel_anim("Idle")
		$Timer.wait_time = rand_range(1, 5)
		$Timer.start()
		
func _on_View_body_entered(body) -> void:
	if body.is_in_group("Player"):
		enemys.append(body)
		set_physics_process(true)

func _on_View_body_exited(body) -> void:
	if body.is_in_group("Player"):
		enemys.erase(body)
		if enemys.size() < 1:
			set_physics_process(false)
			$MoveAt.stop_move()
			$Timer.start()

