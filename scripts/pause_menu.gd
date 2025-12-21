class_name PauseMenu extends CanvasLayer

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var transition: Transition = $Transition

func _ready() -> void:
	hide()

func pause() -> void:
	show()
	animation.play("open")
	get_tree().paused = true

func resume() -> void:
	animation.play("exit")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "exit":
		get_tree().paused = false
		hide()

func _on_back_pressed() -> void:
	resume()

func _on_menu_pressed() -> void:
	transition.change_scene("main_menu")
	get_tree().paused = false
