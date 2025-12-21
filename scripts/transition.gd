class_name Transition extends CanvasLayer

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	show()
	animation.play_backwards("fade_in")

func change_scene(target: String) -> void:
	animation.play("fade_in")
	await animation.animation_finished
	get_tree().change_scene_to_file("res://levels/" + target + ".tscn")
	animation.play_backwards("fade_in")
