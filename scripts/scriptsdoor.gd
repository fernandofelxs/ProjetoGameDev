class_name Door
extends Area2D

@onready var sprite: AnimatedSprite2D = $StaticBody2D/AnimatedSprite2D
@onready var door_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

signal door_activated

var is_open := false
var player_inside := false

func _ready() -> void:
	add_to_group("doors")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false

func try_open_with_key() -> bool:
	if is_open or not player_inside:
		return false

	AudioManager.play_door_open()
	is_open = true
	sprite.play("activated")
	door_collision.set_deferred("disabled", true)
	door_activated.emit()
	return true
