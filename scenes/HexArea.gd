extends Area2D

signal clicked
signal unclicked


func _on_HexArea_input_event(_viewport, _event, shape_idx):
	if shape_idx != 0:
		return
	if Input.is_action_just_pressed("click"):
		emit_signal("clicked")
	if Input.is_action_just_released("click"):
		emit_signal("unclicked")
