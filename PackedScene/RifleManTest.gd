extends KinematicBody2D
onready var bullet : PackedScene = preload("res://PackedScene/Bullet.tscn")

func _physics_process(delta):
	travel_anim("Aim")
	set_anim_direction(get_global_mouse_position())
	$Aim.look_at(get_global_mouse_position())
	
func spaw_b( value : int = 0) -> void:
	var bullet_inst : RigidBody2D = bullet.instance()
	bullet_inst.position = $Aim/Spaw.global_position
	bullet_inst.rotation_degrees = $Aim.rotation_degrees 
	bullet_inst.apply_impulse(Vector2(), Vector2(300, 0).rotated($Aim.rotation + value))
	get_parent().add_child(bullet_inst)
	
func shot() -> void:
	$Particles2D.emitting = true
	spaw_b(0)
	
func travel_anim(anim : String) -> void:
	$AnimationTree.get("parameters/playback").travel(anim)

func update_anim_tree(vector : Vector2) -> void:
	$AnimationTree.set("parameters/Idle/blend_position", vector)
	$AnimationTree.set("parameters/Run/blend_position", vector)
	$AnimationTree.set("parameters/Walk/blend_position", vector)
	$AnimationTree.set("parameters/Aim/blend_position", vector)
	
func set_anim_direction(pos : Vector2) -> void:

	update_anim_tree($Sprite.position.direction_to(pos))
