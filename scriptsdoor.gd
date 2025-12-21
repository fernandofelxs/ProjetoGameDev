class_name Door
extends Area2D

@onready var sprite: AnimatedSprite2D = $StaticBody2D/AnimatedSprite2D
@onready var door_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

signal door_activated

var is_open := false
var player_inside := false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and not is_open and event.is_action_pressed("interact"):
		toggle_door()

func toggle_door() -> void:
	is_open = true

	sprite.play("activated")
	door_collision.set_deferred("disabled", true)
	door_activated.emit()
