extends CharacterBody2D
class_name ship

const ACCELERATION: float = 50
const MAX_SPEED: float = 90
const bullet: PackedScene = preload("res://entities/Ship/bullet.tscn")
@onready var animsprite2d: AnimatedSprite2D = get_node("ThrustAnim")
signal died
signal hit
enum states {
	IDLE,
	MOVING,
	DEAD,
	}
var state: states = states.IDLE
var screenwrapsize: Vector2
var lives: int = 3 # -1 = death.
var is_invulnerable: bool = false

func _ready() -> void:
	hit.connect(_on_self_hit)
	var collisionshape2d: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collisionshape2d != null:
		screenwrapsize = collisionshape2d.get_shape().get_rect().size
		screenwrapsize /= 2
	died.connect(_on_self_died)

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	match state:
		states.IDLE:
			_handle_idle_state(direction)
		states.MOVING:
			_handle_moving_state(direction, delta)
		states.DEAD:
			_handle_dead_state()
	_screen_wrap()
	move_and_slide()

func _handle_idle_state(direction: float) -> void:
	_set_anim("stop")
	if direction or velocity or Input.is_action_pressed("forward"):
		_set_state(states.MOVING)

func _handle_moving_state(direction: float, delta: float) -> void:
	if direction:
		rotate(direction * 3 * delta)
		_set_anim("low")
	
	if Input.is_action_pressed("forward"):
		_set_anim("high")
		velocity += Vector2(0, -ACCELERATION * delta).rotated(rotation)
	elif Input.is_action_pressed("backwards"):
		_set_anim("low")
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)
	else:
		if !direction:
			_set_anim("stop")
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION / 1.5 * delta)
	
	velocity = velocity.clamp(Vector2(-MAX_SPEED, -MAX_SPEED), Vector2(MAX_SPEED, MAX_SPEED))
	if velocity.is_zero_approx() and direction == 0:
		_set_state(states.IDLE)
	
func _handle_dead_state() -> void:
	return

func _shoot() -> void:
	if (get_node("GunTimer") as Timer).is_stopped() == true:
		$ShootSound.play()
		var bullet_instance: Area2D = bullet.instantiate()
		bullet_instance.global_position = get_node("GunPoint").global_position
		bullet_instance.rotation = rotation
		add_sibling(bullet_instance, true)
		get_node("GunTimer").start()

func _set_state(new_state: states) -> void:
	state = new_state

func _screen_wrap() -> void:
	if position.y < 0 - screenwrapsize.y:
		position.y = 240 + screenwrapsize.y
	elif position.y > 240 + screenwrapsize.y:
		position.y = 0 - screenwrapsize.y
	
	if position.x > 320 + screenwrapsize.x:
		position.x = 0 - screenwrapsize.x
	elif position.x < 0 - screenwrapsize.x:
		position.x = 320 + screenwrapsize.x

func _set_anim(anim: String) -> void:
	match anim:
		"stop":
			animsprite2d.play(anim)
		"low":
			animsprite2d.play(anim)
		"high":
			animsprite2d.play(anim)
		_:
			push_warning("Invalid animation string! Ignoring...")

func _on_self_hit() -> void:
	if state == states.DEAD:
		return
	elif lives <= 0 and is_invulnerable != true:
		died.emit()
		_set_state(states.DEAD)
	elif is_invulnerable != true:
		$HitSound.play()
		lives -= 1
		is_invulnerable = true
		velocity = Vector2(0, 75).rotated(rotation)
		for i in range(0, 46):
			get_node("ThrustAnim").visible =! get_node("ThrustAnim").visible
			get_node("Ship").visible =! get_node("Ship").visible
			await get_tree().create_timer(0.033).timeout
		is_invulnerable = false

func _on_self_died() -> void:
	$DeathSound.play()
	$DeathAnim.visible = true
	$DeathAnim.play("default")
	$Ship.visible = false
	$ThrustAnim.visible = false
	is_invulnerable = false
	set_process(false)
	set_physics_process(false)
	await $DeathAnim.animation_finished
	$DeathAnim.visible = false
