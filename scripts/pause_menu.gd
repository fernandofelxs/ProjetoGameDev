class_name PauseMenu extends CanvasLayer

const options_scene = preload("res://levels/options.tscn")

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

func _on_options_pressed() -> void:
	transition.play_fade_in()
	await transition.animation.animation_finished
	var menu_instance: Options = options_scene.instantiate()
	menu_instance.is_paused_mode = true
	add_child(menu_instance)
	transition.play_fade_out()
	hide()
	menu_instance.connect("options_exited", Callable(self, "_on_options_exited"))

func _on_options_exited() -> void:
	show()
	transition.play_fade_out()
