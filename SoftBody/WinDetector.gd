extends Area3D

@export
var nextScene: PackedScene

func _process(_delta: float) -> void:
	var bodies = get_overlapping_bodies()
	if bodies.is_empty():
		get_tree().change_scene_to_packed(nextScene)
