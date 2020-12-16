extends Area2D

var event : bool = false

func _on_RocksEvent_body_entered(body):
	if body.is_in_group("Player") and event:
		get_parent()._end_dialogue()
