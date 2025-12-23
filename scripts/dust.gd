class_name Dust extends Sprite2D

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation.play("default")
