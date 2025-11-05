extends "res://objects/asteroid_base/asteroid_base.gd"

func _init() -> void:
	size = 0

func _on_timer_timeout() -> void:
	despawn = true
	$AnimatedSprite2D.play("despawn")
