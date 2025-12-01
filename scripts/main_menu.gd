extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/room407.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit() # Somente funciona em um jogo exportado, e não no editor
