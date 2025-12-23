class_name MainMenu extends Control

@onready var transition: Transition = $Transition
@onready var anim: AnimationPlayer = $CanvasLayer/AnimationPlayer

func _ready() -> void:
	anim.play("opening")
	AudioManager.play_music_menu()

func _on_play_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/levels/room407.tscn")
	AudioManager.play_ui_click()
	transition.change_scene("initial_cutscene")

func _on_quit_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().quit() 

func _on_options_pressed() -> void:
	AudioManager.play_ui_click()
	transition.change_scene("options")
