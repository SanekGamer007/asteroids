extends Label

func _process(_delta: float) -> void:
	if scoremanager.score >= 999999:
		text = "999999"
		set_process(false)
		return
	else:
		text = "%06d" % scoremanager.score
