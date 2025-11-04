extends CharacterBody2D

const ACCELERATION: float = 50
const MAX_SPEED: float = 90
const bullet: PackedScene = preload("res://entities/Ship/bullet.tscn")
@onready var animsprite2d: AnimatedSprite2D = get_node("AnimatedSprite2D")
signal died
signal hit
enum states {
	IDLE,
	MOVING,
	DEAD,
	}
var state: states = states.IDLE


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
			pass
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
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION / 1.5 * delta)
	
	velocity = velocity.clamp(Vector2(-MAX_SPEED, -MAX_SPEED), Vector2(MAX_SPEED, MAX_SPEED))
	if velocity.is_zero_approx() and direction == 0:
		_set_state(states.IDLE)
	
func _shoot() -> void:
	if (get_node("GunTimer") as Timer).is_stopped() == true:
		var bullet_instance: Area2D = bullet.instantiate()
		bullet_instance.global_position = get_node("GunPoint").global_position
		bullet_instance.rotation = rotation
		add_sibling(bullet_instance, true)
		get_node("GunTimer").start()

func _set_state(new_state: states) -> void:
	state = new_state

func _screen_wrap() -> void:
	if position.y < -10:
		position.y = 250
	elif position.y > 250:
		position.y = -10
	
	if position.x > 326:
		position.x = -6
	elif position.x < -6:
		position.x = 326

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
