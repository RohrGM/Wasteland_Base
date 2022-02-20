extends YSort

var gates: Dictionary = {
	"north": null,
	"south": null,
	"east": null,
	"west": null
}

func set_gate(gate_name: String, gate: Object) -> void:
	gates[gate_name] = gate
	
func get_gate(gate_name) -> Object:
	return gates[gate_name]
