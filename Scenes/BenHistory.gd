extends Navigation2D

onready var slug : PackedScene = preload("res://Slug/Slug.tscn")
onready var aa : PackedScene = preload("res://PackedScene/ActionArea.tscn")

var stage : int = 0
var deaths : int = 0

const ben : Dictionary = {
	0 : {
		0 : "Ahhh.. A vida além da nevoa é melhor do que a maioria pensa",
		1 : "Nenhum daqueles grupos de saqueados e vagabundos vai tão longe, não que seja facil assim atravessar a nevoa, mas em fim...",
		2 : "Sinto te desapontar mas voce escolheu uma historia pacata dessa vez, vou ficar aqui olhando esse milho até ele crescer",
		3 : "(barulho de incetos)",
		4 :  "SE NÃO FOSSE POR ESSAS MALDITAS PRAGAS, CADE MEU GARFO!"
	},
	1 : {
		0 : "Nunca vi tantos assim sair de um buraco só, aposto que os idiotas dos meus visinhos tão tentando perfurar a terra de novo",
		1 : "O chão parece estar tremento, acho que tem mais pragas cavando a terra em baixo de mim, melhor eu ir no Jhon ver que bosta ele ta fazendo"
	}
}


func _ready() -> void:
	$Gui/Dialogue.connect("end_dialogue", self, "_end_dialogue")
	$Gui/Dialogue.start(ben[0], $YSort/Farm)
	$YSort/Farm/Sprite.hide()
	
func _end_dialogue() -> void:
	match(stage):
		0:
			stage = 1
			$YSort/Seated.queue_free()
			$YSort/Farm/Sprite.show()
			spaw_p()
		2:
			$Gui/Objective.text = "Vá até a fazeda de Jhon"
			
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
		
func action_event(var type : String) -> void:
	match(stage):
		2:
			if type == "investigate":
				for i in $YSort/InteractAreas.get_children():
					if i.get_type() == "investigate":
						i.queue_free()
						
				$Gui/Dialogue.start(ben[1], $YSort/Farm)
		
		
func slug_death() -> void:
	if stage == 1:
		deaths += 1
		$Gui/Objective.text = "Elimine as pragas " + String(0 + deaths) + "/15"
		match deaths:
			5: 
				$YSort/Farm/CanvasLayer/Control/Ballon.ballon_text("Merda, sujei minha bota")
			14:
				$YSort/Farm/CanvasLayer/Control/Ballon.ballon_text("Só mais um")
			15: 
				$YSort/Farm/CanvasLayer/Control/Ballon.ballon_text("Da onde que vieram tantos?")
				$Gui/Objective.text = "Investigue a causa da pragas"
				$Gui/TextureRect.show()
				
				var area : Area2D = aa.instance()
				area.connect("action", self, "action_event")
				area.set_type("investigate")
				$YSort/InteractAreas.call_deferred("add_child", area)
				area.position = Vector2(-252, -17)
				
				area = aa.instance()
				area.connect("action", self, "action_event")
				area.set_type("investigate")
				$YSort/InteractAreas.call_deferred("add_child", area)
				area.position = Vector2(-11, 112)
				stage = 2
				
				
	
			
