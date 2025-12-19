class_name Lever extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal lever_activated

func _on_body_entered(body: Node2D) -> void:
	if body is Player and Input.is_action_just_pressed("interact"):
		sprite.play("activated")
		lever_activated.emit()
