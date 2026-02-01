extends Area3D

func _process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	if bodies.is_empty():
		print("YOU WIN!")
