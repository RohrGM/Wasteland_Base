extends Navigation2D

onready var slug : PackedScene = preload("res://Slug.tscn")

var stage : int = 0
var deaths : int = 0

const ben : Dictionary = {
	0 : {
		0 : "Ahhh.. A vida além da nevoa é melhor do que a maioria pensa",
		1 : "Nenhum daqueles grupos de saqueados e vagabundos vai tão longe, não que seja facil assim atravessar a nevoa, mas em fim...",
		2 : "Sinto te desapontar mas voce escolheu uma historia pacata dessa vez, vou ficar aqui olhando esse milho até ele crescer",
		3 : "(barulho de incetos)",
		4 :  "SE NÃO FOSSE POR ESSAS MALDITAS PRAGAS, CADE MEU GARFO!"
	}
}


func _ready() -> void:
	$Gui/Dialogue.connect("end_dialogue", self, "_end_dialogue")
	$Gui/Dialogue.start(ben[0])
	$YSort/Farm.player(false)
	$YSort/Farm.set_cam(Vector2(.5, .5))
	$YSort/Farm/Sprite.hide()
	
func _end_dialogue() -> void:
	match(stage):
		0:
			stage += 1
			$YSort/Seated.queue_free()
			$YSort/Farm.player(true)
			$YSort/Farm.set_cam(Vector2(1, 1))
			$YSort/Farm/Sprite.show()
			spaw_p()
			
func spaw_p() -> void:
	var points : Array = []
	
	for _i in range(15):
		randomize()
		if int(rand_range(0,2)) == 1:
			points.append(Vector2(-13, 116))
		else:
			points.append(Vector2(-250, -12))
	
	for p in points:
		var slug_inst : KinematicBody2D = slug.instance()
		$YSort.add_child(slug_inst)
		slug_inst.position = p
		slug_inst.connect("death", self, "slug_death")
		
func slug_death() -> void:
	if stage == 1:
		deaths += 1
		$Gui/Objective.text = "Elimine as pragas " + String(15 - deaths) + "/15"
		match deaths:
			5: 
				$YSort/Farm/CanvasLayer/Ballon.ballon_text("Merda, sujei minha bota")
			14:
				$YSort/Farm/CanvasLayer/Ballon.ballon_text("Só mais um")
			15: 
				$YSort/Farm/CanvasLayer/Ballon.ballon_text("Da onde que vieram tantos?")
				$Gui/Objective.text = "Investigue a causa da pragas"
	
			
