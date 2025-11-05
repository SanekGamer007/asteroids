extends Node
signal asteroid_destroyed(size: int)
var asteroids: int
const big_asteroid = preload("res://objects/asteroid_big/asteroid_big.tscn")
const medium_asteroid = preload("res://objects/asteroid_medium/asteroid_medium.tscn")
const small_asteroid = preload("res://objects/asteroid_small/asteroid_small.tscn")
@onready var Ship: ship = get_tree().get_first_node_in_group("ship")
@onready var timer: Timer = get_tree().root.get_node("/root/Game/AsteroidSpawnOpportunity") # im tired of writing good non hardcoded code.

func _ready() -> void:
	Ship.died.connect(_on_ship_died)
	asteroid_destroyed.connect(_on_self_asteroid_destroyed)
	_on_asteroid_spawn_opportunity_timeout(0)
	timer.timeout.connect(_on_asteroid_spawn_opportunity_timeout)

func _process(_delta: float) -> void:
	asteroids = get_tree().get_nodes_in_group("asteroid").size()
	if asteroids <= 2:
		_on_asteroid_spawn_opportunity_timeout(2)

func _on_self_asteroid_destroyed(size: int) -> void:
	scoremanager.update_score(size)

func _on_asteroid_spawn_opportunity_timeout(size: int = -1) -> void:
	if asteroids <= 16:
		var direction: int = randi_range(0, 3) # 0 = left, 1 = right, 2 = up, 3 = down
		var x: float
		var y: float
		var asteroid: Area2D
		var ass: PackedScene
		if size == -1:
			size = randi_range(1, 2) # 0 = small, 1 = medium, 2 = big
		match size:
			0:
				ass = small_asteroid
			1:
				ass = medium_asteroid
			2:
				ass = big_asteroid
			_:
				push_warning("Invalid asteroid size! Skipping spawn opportunity...")
				return
		asteroid = ass.instantiate()
		if direction <= 1:
			y = randf_range(0, 240)
			if direction == 0:
				asteroid.position = Vector2(-32, y)
			else:
				asteroid.position = Vector2(352, y)
		else:
			x = randf_range(0, 320)
			if direction == 2:
				asteroid.position = Vector2(x, 262)
			else:
				asteroid.position = Vector2(x, -32)
		get_tree().root.get_node("/root/Game").add_child(asteroid, true)

func _on_ship_died() -> void:
	timer.timeout.disconnect(_on_asteroid_spawn_opportunity_timeout)
