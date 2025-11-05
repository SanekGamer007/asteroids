extends Label

@onready var Ship: ship = get_tree().get_first_node_in_group("ship")

func _process(_delta: float) -> void:
	text = str(Ship.lives)
