class_name GameController extends Node2D

@onready var pause_menu: PauseMenu = $PauseMenu

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("paused") and not get_tree().paused:
		pause_menu.pause()
