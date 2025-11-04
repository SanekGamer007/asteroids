extends Area2D
const SPEED = 2.5
var screenwrapsize: Vector2

func _ready() -> void:
	var collisionshape2d: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collisionshape2d != null:
		screenwrapsize = collisionshape2d.get_shape().get_rect().size
		screenwrapsize /= 2

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
		body.emit_signal("hit")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship"):
		return
	else:
		area.emit_signal("hit")
		queue_free()

func _screen_wrap() -> void:
	if position.y < 0 - screenwrapsize.y:
		position.y = 240 + screenwrapsize.y
	elif position.y > 240 + screenwrapsize.y:
		position.y = 0 - screenwrapsize.y
	
	if position.x > 320 + screenwrapsize.x:
		position.x = 0 - screenwrapsize.x
	elif position.x < 0 - screenwrapsize.x:
		position.x = 320 + screenwrapsize.x
