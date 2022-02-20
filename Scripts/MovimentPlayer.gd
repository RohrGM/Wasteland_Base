extends Node

onready var body: KinematicBody2D = get_parent()

const ACCELERATION : int = 550
const MAX_SPEED : int = 50
const FRICTION : int = 200

var velocity : Vector2 = Vector2.ZERO

func _physics_process(_delta):
	var input_vector : Vector2 = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	velocity = body.move_and_slide(velocity)
