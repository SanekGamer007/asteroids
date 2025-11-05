extends Sprite2D
@onready var Ship: ship = get_tree().get_first_node_in_group("ship")

func _ready() -> void:
	Ship.died.connect(_on_ship_died)
	set_process(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		get_tree().reload_current_scene()
		self.process_mode = Node.PROCESS_MODE_INHERIT
		set_process(false)

func _on_ship_died() -> void:
	await get_tree().create_timer(1).timeout
	visible = true
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
