extends Label3D

var startTime: int

func _ready() -> void:
	startTime = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	@warning_ignore("integer_division")
	text = var_to_str((Time.get_ticks_msec() - startTime) / 1000)
