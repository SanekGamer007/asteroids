extends Area2D

const SPEED = 2
func _physics_process(_delta: float) -> void:
	position += Vector2(0, -SPEED).rotated(rotation)
	_screen_wrap()


func _on_death_timer_timeout() -> void:
	#for i in range(0, 24):
	#	modulate.a8 -= 1 * i # too cool for the games style
	#	await get_tree().create_timer(0.016).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ship"):
		return
	else:
		body.hit.emit()

func _screen_wrap() -> void:
	if position.y < -10:
		position.y = 250
	elif position.y > 250:
		position.y = -10
	
	if position.x > 326:
		position.x = -6
	elif position.x < -6:
		position.x = 326
