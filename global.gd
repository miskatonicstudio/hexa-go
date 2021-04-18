extends Node

signal source_cell_selected (cell)
signal target_cell_selected (cell)

var TOKENS = {
	1: [],
	2: [],
}

func _ready():
	randomize()
	for player in [1,2]:
		for token in range(2, 36):
			TOKENS[player].append(token)
		TOKENS[player].shuffle()
		TOKENS[player].push_front(1)

func get_token(player):
	return TOKENS[player].pop_front()
