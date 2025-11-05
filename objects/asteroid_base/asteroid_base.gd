extends Area2D
@export var next_size_scene: PackedScene
@export var asteroid_bits: int = 4
@export var offsets: Array[Vector2] ## array should NOT be bigger than asteroids bits
@export var speedmin: float = 1
@export var speedmax: float = 5
var screenwrapsize: Vector2
var size = -1 # template
var despawn: bool = false


var speed: float
var deg_to_move: float
var velocity_vector: Vector2
signal hit

func _ready() -> void:
	hit.connect(_on_self_hit)
	speed = randf_range(speedmin, speedmax)
	deg_to_move = (deg_to_rad(randf_range(-180, 180)))
	velocity_vector = Vector2(0, -speed / 10).rotated(deg_to_move)
	var collisionshape2d: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collisionshape2d != null:
		screenwrapsize = collisionshape2d.get_shape().get_rect().size
		screenwrapsize /= 2

func _physics_process(_delta: float) -> void:
	position += velocity_vector
	_screen_wrap()

func _on_self_hit() -> void:
	$AnimatedSprite2D.play("destroy")
	$HitSound.play()

func _screen_wrap() -> void:
	if position.y < 0 - screenwrapsize.y:
		position.y = 240 + screenwrapsize.y
	elif position.y > 240 + screenwrapsize.y:
		position.y = 0 - screenwrapsize.y
	
	if position.x > 320 + screenwrapsize.x:
		position.x = 0 - screenwrapsize.x
	elif position.x < 0 - screenwrapsize.x:
		position.x = 320 + screenwrapsize.x

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ship"):
		body.emit_signal("hit")


func _on_animated_sprite_2d_animation_finished() -> void:
	if next_size_scene != null:
		if offsets.size() == 0:
			for i in asteroid_bits:
				offsets.append(Vector2(0,0))
		for i in asteroid_bits:
			var scene: Node2D = next_size_scene.instantiate()
			scene.position = self.position + offsets[i]
			call_deferred("add_sibling", scene, true)
	if despawn == false:
		game.emit_signal("asteroid_destroyed", size)
	self.queue_free()
