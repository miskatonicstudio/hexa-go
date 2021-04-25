extends Node2D


export (int) var belongs_to = 0

onready var sprite = $Sprite
onready var label = $WoundCount
onready var rotation_indicator = $RotationIndicator

var rotation_in_progress = false
var original_rotation_point = null
var original_token_rotation = null

var wound_count = 0 setget set_wound_count


func initialize(belongs_to, number):
	self.belongs_to = belongs_to
	if belongs_to == 1:
		sprite.modulate = Color.cyan
	elif belongs_to == 2:
		sprite.modulate = Color.orange
	sprite.texture = load("res://tokens/%d.png" % number)


func set_wound_count(value):
	value = max(0, value)
	wound_count = value
	if wound_count > 0:
		label.text = str(wound_count)
	else:
		label.text = ""


func begin_rotation():
	rotation_indicator.show()


func disable_rotation():
	rotation_indicator.hide()


func is_rotation_enabled():
	return rotation_indicator.visible


func _input(event):
	if Input.is_action_just_released("click"):
		rotation_in_progress = false
		var final_angle = snap(sprite.rotation_degrees, 360, 6)
		sprite.rotation_degrees = final_angle
	if rotation_in_progress and event is InputEventMouseMotion:
		var new_rotation_position = label.get_local_mouse_position()
		var angle = original_rotation_point.angle_to(new_rotation_position)
		angle = rad2deg(angle)
		sprite.rotation_degrees = original_token_rotation + angle


func _on_Rotator_input_event(_viewport, event, _shape_idx):
	if is_rotation_enabled():
		if Input.is_action_just_pressed("click"):
			rotation_in_progress = true
			original_rotation_point = label.get_local_mouse_position()
			original_token_rotation = sprite.rotation_degrees


func snap(value, max_value, steps):
	value = wrapf(value, 0, max_value)
	return int(steps*(value + max_value*0.5/steps)/max_value) * (max_value/steps)
