class_name Bullet extends StaticBody2D

@export var speed: int = 1000
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))
	area.connect("body_entered", Callable(self, "_on_bullet_collide"))
	
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
 
func _on_screen_exited() -> void:
	queue_free()

func _on_bullet_collide(body: Node2D) -> void:
	if body is Enemy or body is BaseEnemy:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(50, knockback_direction)
		queue_free()
