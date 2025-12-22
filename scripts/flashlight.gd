class_name Flashlight extends Node2D

@onready var prop_scale_y: float = scale.y
@onready var sprite: Sprite2D = $Sprite2D

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
 
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -prop_scale_y
	else:
		scale.y = prop_scale_y
