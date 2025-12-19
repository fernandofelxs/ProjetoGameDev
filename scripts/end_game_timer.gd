extends Timer

func _ready() -> void:
	wait_time = 4.0
	one_shot = true
	autostart = true
	timeout.connect(_on_timeout)

func _on_timeout() -> void:
	get_tree().quit()
