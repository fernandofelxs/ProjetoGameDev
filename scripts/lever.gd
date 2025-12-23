class_name Lever extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow: Sprite2D = $Arrow
var player_found: bool = false
var activated: bool = false
signal lever_activated

func _ready() -> void:
	arrow.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_found and not activated:
		arrow.hide()
		sprite.play("activated")
		activated = true
		lever_activated.emit()	

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not activated:
		arrow.show()
		player_found = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player and not activated:
		arrow.hide()
		player_found = false
