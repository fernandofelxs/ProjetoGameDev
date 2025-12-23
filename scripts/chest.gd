class_name Chest extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var marker: Marker2D = $Marker2D
@export var scene: Node2D = null

var is_player_found: bool = false

func _ready() -> void:
	arrow.hide()
	sprite.play("default")

func _process(_delta: float) -> void:
	if is_player_found and Input.is_action_just_pressed("interact"):
		sprite.play("open")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_found = true
		
		if sprite.animation == "default":
			arrow.show()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_found = false
		arrow.hide()

func _on_animated_sprite_2d_animation_finished() -> void:
	if scene:
		scene.global_position = marker.global_position
