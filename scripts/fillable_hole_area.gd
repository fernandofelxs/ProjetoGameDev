class_name Hole
extends Area2D

signal hole_triggered
@export var tilemap: TileMap
@export var layer := 0
@export var wood_atlas_coords := Vector2i(2, 0)

var player_inside := false
var is_filled := false

func _ready() -> void:
	add_to_group("holes")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false

func try_fill_with_plank() -> bool:
	if is_filled or not player_inside:
		return false
	hole_triggered.emit()

	queue_free()
	return true
