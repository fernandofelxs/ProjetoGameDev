class_name BulletPickup extends Area2D

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.can_switch:
		body.add_bullets(1)
		queue_free()
