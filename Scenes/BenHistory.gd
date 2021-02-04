extends Navigation2D

onready var slug : PackedScene = preload("res://Slug/Slug.tscn")
onready var aa : PackedScene = preload("res://PackedScene/ActionArea.tscn")
onready var msg : PackedScene = preload("res://PackedScene/WordMessage.tscn")
onready var tls : PackedScene = preload("res://PackedScene/ToolsAnim.tscn")
onready var vgt : PackedScene = preload("res://PackedScene/Vagrant.tscn")

var slugs : int = 0
var food : int = 2
var wood : int = 2

enum{
	AXE,
	FORK,
	RIFLE
}

func _ready() -> void:
	$Gui/TimeControl.connect("horde", self, "horde_from_hell")
	$Gui/TimeControl.connect("new_day", self, "new_day")
	
	update_food()
	update_wood()
	
	for i in $InteractAreas.get_children():
		i.connect("action", self, "action_event")
		
#	for i in $YSort/YSort.get_children():
#		i.connect("death", self, "slug_dead")

func remove_food(var value : int) -> bool:
	if food - value >= 0:
		food -= value
		update_food()
		return true
		
	update_food()
	return false
	
func add_food(var value : int) -> void:
	food += value
	update_food()

func update_food() -> void:
	$Gui/Resources/Food.text = String(food)
	
func update_wood() -> void:
	$Gui/Resources/Wood.text = String(wood)
	
func remove_wood(var value : int) -> bool:
	if wood - value >= 0:
		wood -= value
		update_wood()
		return true
	return false
	
func add_wood(var value : int) -> void:
	wood += value
	update_wood()
		
func VagrantSp() -> void:
	randomize()
	var spPos : Vector2 = $Spaws/Horde.get_child(randi()%3).position
	var vagrant : KinematicBody2D = vgt.instance()
	$YSort.call_deferred("add_child", vagrant)
	vagrant.position = spPos
		
func horde_from_hell() -> void:
	randomize()
	var spPos : Vector2 = $Spaws/Horde.get_child(randi()%3).position

	for i in range(int($Gui/TimeControl.get_day() * 5 )):
		var monster : KinematicBody2D = slug.instance()
		$YSort.call_deferred("add_child", monster)
		monster.position = spPos + Vector2(rand_range(-10, 10), rand_range(-10 , 10))
		monster.set_home(Vector2(-6, -10))
		$Timer.start()
		yield($Timer, "timeout")
		
func new_day() -> void:
	VagrantSp()

func message(var txt : String, var pos : Vector2) -> void:
	var wordMessage : Label = msg.instance()
	wordMessage.text = txt
	get_parent().add_child(wordMessage)
	wordMessage.rect_position = Vector2(pos.x - (txt.length() *4), pos.y - 50)

func action_event(var type : String, var area : Area2D) -> void:
	if type == "newhome":
		message("Um novo lar", area.position)
		area.queue_free()
		
func spawTools(var type : int, var pos : Vector2) -> void:
	var tools : Sprite = tls.instance()
	$YSort.add_child(tools)
	tools.type = type
	tools.position = pos
	
func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		$YSort/Fireplace/AnimationPlayer.current_animation = "fire"
		$YSort/Fireplace/Particles2D.emitting = true
		$Timer.wait_time = 2
		$Timer.start()
		yield($Timer, "timeout")
		message("Eles virão até o fogo", $YSort/Fireplace.position)
		$Timer.start()
		yield($Timer, "timeout")
		spawTools(AXE, Vector2(-87, -11))
		spawTools(RIFLE, Vector2(90, -12))
		$Area2D.queue_free()

func slug_dead() -> void:
	pass
#	slugs += 1
#
#	if slugs == 11:
#		$YSort/YSort.queue_free()
#		$YSort/Fireplace/AnimationPlayer.current_animation = "fire"
#		$YSort/Fireplace/Particles2D.emitting = true
#		$Timer.wait_time = 2
#		$Timer.start()
#		yield($Timer, "timeout")
#		message("Eles virão até o fogo", $YSort/Fireplace.position)
#		$Timer.start()
#		yield($Timer, "timeout")
#		spawTools(AXE, Vector2(-144, -12))
#		spawTools(RIFLE, Vector2(113, -12))
#		VagrantSp()
#		VagrantSp()
















































#var stage : int = 0
#var deaths : int = 0
#
#const ben : Dictionary = {
#	0 : {
#		0 : "Ahhh.. A vida além da nevoa é melhor do que a maioria pensa",
#		1 : "Nenhum daqueles grupos de saqueados e vagabundos vai tão longe, não que seja facil assim atravessar a nevoa, mas em fim...",
#		2 : "Sinto te desapontar mas voce escolheu uma historia pacata dessa vez, vou ficar aqui olhando esse milho até ele crescer",
#		3 : "(barulho de incetos)",
#		4 :  "SE NÃO FOSSE POR ESSAS MALDITAS PRAGAS, CADE MEU GARFO!"
#	},
#	1 : {
#		0 : "Nunca vi tantos assim sair de um buraco só, aposto que os idiotas dos meus visinhos tão tentando perfurar a terra de novo",
#		1 : "O chão parece estar tremento, acho que tem mais pragas cavando a terra em baixo de mim, melhor eu ir no Jhon ver que bosta ele ta fazendo"
#	}
#}
#
#
#func _ready() -> void:
#	$Gui/Dialogue.connect("end_dialogue", self, "_end_dialogue")
#	$Gui/Dialogue.start(ben[0], $YSort/Farm)
#	$YSort/Farm/Sprite.hide()
#
#func _end_dialogue() -> void:
#	match(stage):
#		0:
#			stage = 1
#			$YSort/Seated.queue_free()
#			$YSort/Farm/Sprite.show()
#			spaw_p()
#		2:
#			$Gui/Objective.text = "Vá até a fazeda de Jhon"
#
#func spaw_p() -> void:
#	var points : Array = []
#
#	for _i in range(15):
#		randomize()
#		if int(rand_range(0,2)) == 1:
#			points.append(Vector2(-13, 116))
#		else:
#			points.append(Vector2(-250, -12))
#
#	for p in points:
#		var slug_inst : KinematicBody2D = slug.instance()
#		$YSort.add_child(slug_inst)
#		slug_inst.position = p
#		slug_inst.connect("death", self, "slug_death")
#
#func action_event(var type : String) -> void:
#	match(stage):
#		2:
#			if type == "investigate":
#				for i in $YSort/InteractAreas.get_children():
#					if i.get_type() == "investigate":
#						i.queue_free()
#
#				$Gui/Dialogue.start(ben[1], $YSort/Farm)
#
#
#func slug_death() -> void:
#	if stage == 1:
#		deaths += 1
#		$Gui/Objective.text = "Elimine as pragas " + String(0 + deaths) + "/15"
#		match deaths:
#			5: 
#				$YSort/Farm/CanvasLayer/Control/Ballon.ballon_text("Merda, sujei minha bota")
#			14:
#				$YSort/Farm/CanvasLayer/Control/Ballon.ballon_text("Só mais um")
#			15: 
#				$YSort/Farm/CanvasLayer/Control/Ballon.ballon_text("Da onde que vieram tantos?")
#				$Gui/Objective.text = "Investigue a causa da pragas"
#				$Gui/TextureRect.show()
#
#				var area : Area2D = aa.instance()
#				area.connect("action", self, "action_event")
#				area.set_type("investigate")
#				$YSort/InteractAreas.call_deferred("add_child", area)
#				area.position = Vector2(-252, -17)
#
#				area = aa.instance()
#				area.connect("action", self, "action_event")
#				area.set_type("investigate")
#				$YSort/InteractAreas.call_deferred("add_child", area)
#				area.position = Vector2(-11, 112)
#				stage = 2
#
#
#
#


