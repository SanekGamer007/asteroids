extends Node
var score: int
const small_asteroid: int = 100
const medium_asteroid: int = 50
const big_asteroid: int = 25


func update_score(size: int) -> void: # 0 = small, 1 = medium, 2 = big
	match size:
		0: score += small_asteroid
		1: score += medium_asteroid
		2: score += big_asteroid
