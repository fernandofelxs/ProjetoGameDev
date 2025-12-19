extends Area2D

@export var target_scene_name: String
var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if triggered:
		return

	if body is Player:
		triggered = true

		var transition = $"../Transition"
		if transition:
			transition.change_scene(target_scene_name)
		else:
			push_error("Transition node not found!")
