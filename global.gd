extends Node

signal unlock
signal lock
signal cell_selected (cell)

var TOKENS = {
	1: [],
	2: [],
}
# TODO: implement discards

func _ready():
	randomize()
	for player in [1,2]:
		for token in range(2, 36):
			TOKENS[player].append(token)
		TOKENS[player].shuffle()
		TOKENS[player].push_front(1)
	
	get_tree().connect("node_added", self, "_on_node_added")


func get_token(player):
	return TOKENS[player].pop_front()


func _on_node_added(node):
	# TODO: this is used only in tokens, move it there
	if "belongs_to:1" in node.get_groups():
		node.self_modulate = Color.cyan
	if "belongs_to:2" in node.get_groups():
		node.self_modulate = Color.orange
