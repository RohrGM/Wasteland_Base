extends Navigation2D

var stage : int = 0

const ben : Dictionary = {
	0 : {
		0 : "Nunca pensei que pudessem fazer tuneis tão grandes",
		1 : "(barulho de incetos)",
		2 : "Tem mais por perto, preciso ter cuidado"
	},
	1 : {
		0 : "Aquela gelatina de carne ta parindo um milhão desses merdas!",
		1 : "Preciso avisar os outros do que está acontecendo aqui!",
		2 : "Se ela continuar gerando mais filhos, eles vão destruir tudo que encontrarem.",
		3 : "O Will.... Preciso achar ele!"
	},
	2 : {
		0 : "Não vou conseguir voltar por onde eu vim.",
		1 : "Se eu achar o Will posso sair por onde ele veio!"
	}
}


func _ready() -> void:
	$Gui/Dialogue.connect("end_dialogue", self, "_end_dialogue")
	$Gui/Dialogue.start(ben[0])
	$YSort/Farm.player(false)
	$YSort/Farm.set_cam(Vector2(.5, .5))
	
func _end_dialogue() -> void:
	print(stage)
	match(stage):
		0:
			stage += 1
			$YSort/Farm.player(true)
			$YSort/Farm.set_cam(Vector2(1, 1))
			$YSort/Farm.add_item("s12")
			$YSort/Farm.add_item("fork")
		1:
			stage += 1
			$YSort/Farm.player(false)
			$YSort/Farm.set_cam(Vector2(.5, .5))
			$MotherEvent.queue_free()
			$Gui/Dialogue.start(ben[1])
		2:
			stage += 1
			$YSort/Farm.player(true)
			$YSort/Farm.set_cam(Vector2(1, 1))
			$TileMap.set_cellv(Vector2(3, -10), 0)
			$TileMap.set_cellv(Vector2(2, -10), 0)
			$RocksEvent.event = true
		3:
			stage += 1
			$YSort/Farm.player(false)
			$YSort/Farm.set_cam(Vector2(.5, .5))
			$RocksEvent.queue_free()
			$Gui/Dialogue.start(ben[2])
		4: 
			stage += 1
			$YSort/Farm.player(true)
			$YSort/Farm.set_cam(Vector2(1, 1))

			
			
