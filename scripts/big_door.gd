class_name BigDoor extends StaticBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@export var lever: Lever = null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var camera: Camera2D = null
var tween: Tween = null

func _ready() -> void:
	animation.play("default")
	if lever:
		lever.connect("lever_activated", Callable(self, "_on_lever_activated"))

func open_door() -> void:
	animation.play("open")

func _on_lever_activated() -> void:
	if camera:
		update_camera_position()
	else:
		open_door()

func update_camera_position() -> void:
	var old_camera_position: Vector2 = camera.global_position
	
	await get_tree().create_timer(0.5).timeout
	
	tween = create_tween()
	tween.tween_property(
		camera, 
		"global_position",
		global_position,
		0.5
	)
	tween.play()
	
	await get_tree().create_timer(0.7).timeout
	
	open_door()
	
	await get_tree().create_timer(0.7).timeout
	
	tween.tween_property(
		camera, 
		"global_position",
		old_camera_position,
		0.5
	)
	tween.play()	
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	collision_shape.set_deferred("disabled", true)
