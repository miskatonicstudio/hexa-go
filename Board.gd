extends Node2D


func _on_AddWound_pressed():
	for token in get_all_activated_board_tokens():
		token.wound_count += 1


func _on_RemoveWound_pressed():
	for token in get_all_activated_board_tokens():
		token.wound_count -= 1


func get_all_activated_board_tokens():
	var tokens = []
	for cell in get_tree().get_nodes_in_group("board"):
		var token = cell.get_token()
		if cell.is_activated():
			tokens.append(token)
	return tokens
