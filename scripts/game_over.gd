class_name GameOver extends CanvasLayer

@onready var transition: Transition = $Transition

func _on_timer_timeout() -> void:
	transition.change_scene("main_menu")
