extends Control

@onready var transition: Transition = $Transition

func _on_play_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/levels/room407.tscn")
	transition.change_scene("room407")

func _on_quit_pressed() -> void:
	get_tree().quit() 
