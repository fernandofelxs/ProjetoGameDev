extends Node2D

@export var max_radius: float = 110.0
@export var lifetime: float = 0.7
@export var ring_width: float = 6.0

var _elapsed: float = 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()

	if _elapsed >= lifetime:
		queue_free()

func _draw() -> void:
	var t: float = clamp(_elapsed / lifetime, 0.0, 1.0)

	# Shockwave expansion
	var current_radius: float = max_radius * t

	# Fade out
	var alpha: float = lerp(0.7, 0.0, t)

	if current_radius <= 1.0:
		return

	draw_arc(
		Vector2.ZERO,
		current_radius,
		0.0,
		TAU,
		128,
		Color(0.5, 0.0, 0.8, alpha),
		ring_width,
		true
	)
