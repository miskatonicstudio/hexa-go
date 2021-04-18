extends Node2D

const COLOR_ACTIVATED = Color.blue
const COLOR_HIGHLIGHTED = Color.yellow
const COLOR_NORMAL = Color.white

export (int, "None", "A", "B") var belongs_to = 0
export (int, "Board", "Stack", "Discard", "Hand") var type = 0

onready var sprite = $Sprite

var blocked = false


func _ready():
	global.connect("target_cell_selected", self, "_on_tcs")
	global.connect("source_cell_selected", self, "_on_scs")


func activate():
	if blocked:
		return
	var groups = get_groups()
	var token = get_token()
	if "stack" in groups and not is_activated():
		sprite.self_modulate = COLOR_ACTIVATED
		global.emit_signal("source_cell_selected", self)
		for cell in get_tree().get_nodes_in_group("hand"):
			if cell.belongs_to == self.belongs_to:
				cell.highlight_as_target()
	elif "hand" in groups and token and not is_activated():
		sprite.self_modulate = COLOR_ACTIVATED
		global.emit_signal("source_cell_selected", self)
		for cell in get_tree().get_nodes_in_group("discard"):
			if cell.belongs_to == self.belongs_to:
				cell.highlight_as_target()
		for cell in get_tree().get_nodes_in_group("board"):
			cell.highlight_as_target()
	elif "board" in groups and token and not is_activated():
		sprite.self_modulate = COLOR_ACTIVATED
		global.emit_signal("source_cell_selected", self)
		for cell in get_tree().get_nodes_in_group("discard"):
			# TODO: check ownership of a token, not of a cell
			if cell.belongs_to == token.belongs_to:
				cell.highlight_as_target()
		for cell in get_tree().get_nodes_in_group("board"):
			cell.highlight_as_target()
				# TODO: signal for showing discard
	else: # sprite.self_modulate == COLOR_HIGHLIGHTED:
		global.emit_signal("target_cell_selected", self)


func highlight_as_target():
	var token = get_token()
	if not token:
		sprite.self_modulate = COLOR_HIGHLIGHTED
		blocked = false


func _on_scs(source):
	if source != self:
		blocked = true


func _on_tcs(destination):
	blocked = false
	var token = get_token()
	var groups = get_groups()
	if destination == self and is_activated():
		if "board" in groups:
#			blocked = true
			if token.is_rotation_enabled():
				token.disable_rotation()
				sprite.self_modulate = COLOR_NORMAL
#				blocked = false
			else:
#				blocked = true
				token.begin_rotation()
		# TODO: block until token rotation is done
		else:
			sprite.self_modulate = COLOR_NORMAL
		return
#	if "board" in destination.get_groups():
#		return
	if is_activated():
		var new_token = load("res://Token.tscn").instance()
		if "stack" in groups and not "stack" in destination.get_groups():
			var number = global.get_token(belongs_to)
			if number != null:
				destination.add_child(new_token)
				new_token.initialize(belongs_to, number)
		if "board" in destination.get_groups():
			self.remove_child(token)
			destination.add_child(token)
#			blocked = true
			token.begin_rotation()
		elif token and "discard" in destination.get_groups():
			remove_child(token)
			# TODO: send signal and add discarded token to the list
	sprite.self_modulate = COLOR_NORMAL


func _on_Area2D_input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and shape_idx == 0:
		activate()


func get_token():
	for child in get_children():
		if child.name.find("Token") >= 0:
			return child
	return null


func is_activated():
	return sprite.self_modulate == COLOR_ACTIVATED
