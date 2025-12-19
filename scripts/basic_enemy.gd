class_name BaseEnemy extends CharacterBody2D

@export var target: Player

var speed: int = 20

func _physics_process(delta: float) -> void:
	if target:
		var direction: Vector2 = (target.position - position).normalized()
		velocity = direction * speed
		look_at(target.position)
		move_and_slide()
