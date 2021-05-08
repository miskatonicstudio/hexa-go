extends Node2D


export (int) var belongs_to = 0
export var token_number = 0

onready var center_label = $CenterContainer
onready var wound_count_label = $CenterContainer/WoundCount
onready var rotation_indicator = $RotationIndicator
onready var area = $HexArea
onready var timer = $Timer

onready var wound_add = $HexAreaWoundAdd
onready var wound_remove = $HexAreaWoundRemove
onready var long_timer = $LongTimer
var sprite = null

var rotation_in_progress = false
var original_rotation_point = null
var original_token_rotation = null

var wound_count = 0 setget set_wound_count


func initialize(belongs_to, token_number):
	# TODO: refactor this logic and `_ready` method
	"""This should be called before _ready"""
	self.belongs_to = belongs_to
	self.token_number = token_number
	sprite = get_node("Sprite")
	sprite.add_to_group("belongs_to:" + str(belongs_to))
	sprite.texture = load("res://tokens/%d.png" % token_number)


func set_wound_count(value):
	value = max(0, value)
	wound_count = value
	if wound_count > 0:
		wound_count_label.text = str(wound_count)
		if token_number == 1:
			wound_count_label.text += "/20"
	else:
		if token_number == 1:
			wound_count_label.text = "0/20"
		else:
			wound_count_label.text = ""


func _input(event):
	if Input.is_action_just_released("click"):
		long_timer.stop()
		rotation_in_progress = false
		var final_angle = snap(sprite.rotation_degrees, 360, 6)
		sprite.rotation_degrees = final_angle
	if rotation_in_progress and event is InputEventMouseMotion:
		long_timer.stop()
		var new_rotation_position = center_label.get_local_mouse_position()
		var angle = original_rotation_point.angle_to(new_rotation_position)
		angle = rad2deg(angle)
		sprite.rotation_degrees = original_token_rotation + angle


func snap(value, max_value, steps):
	value = wrapf(value, 0, max_value)
	return int(
		steps*(value + max_value*0.5/steps)/max_value) * (max_value/steps
	)


func _on_Timer_timeout():
	# Longer click = start rotation
	if not wound_add.visible:
		rotation_in_progress = true
		original_rotation_point = center_label.get_local_mouse_position()
		original_token_rotation = sprite.rotation_degrees


func activate():
	rotation_indicator.show()
	area.input_pickable = true
	long_timer.start()
	set_wound_count(self.wound_count)


func deactivate():
	rotation_indicator.hide()
	set_wound_ui(false)
	area.input_pickable = false


func is_activated():
	return area.input_pickable


func _on_HexArea_clicked():
	timer.start()
	long_timer.start()


func _on_HexArea_unclicked():
	if timer.time_left:
		# Short click = token "deactivated"
		deactivate()
		global.emit_signal("unlock")
		timer.stop()
		long_timer.stop()


func _on_HexAreaWoundAdd_clicked():
	self.wound_count += 1


func _on_HexAreaWoundRemove_clicked():
	self.wound_count -= 1


func _on_LongTimer_timeout():
	# Really long click = show wound menu
	set_wound_ui(true)
	global.emit_signal("lock")


func set_wound_ui(visible):
	wound_add.visible = visible
	wound_add.input_pickable = visible
	wound_remove.visible = visible
	wound_remove.input_pickable = visible
	if visible:
		rotation_in_progress = false
		rotation_indicator.hide()
