class_name Screenshake extends Node

@export var random_strength: float = 30.0
@export var shake_fade: float = 5.0
@export var camera: Camera2D = null

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake() -> void:
	shake_strength = random_strength

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade + delta)
		if camera:
			camera.offset += random_offset()

func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)
