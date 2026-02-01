extends Label3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	@warning_ignore("integer_division")
	text = var_to_str(Time.get_ticks_msec() / 1000)
