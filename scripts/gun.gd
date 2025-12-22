class_name Gun extends Node2D

@onready var muzzle: Marker2D = $Muzzle
const bullet = preload("res://scenes/gun/bullet.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var prop_scale_y: float = scale.y
@onready var timer: Timer = $Timer
var shooting: bool = false
@export var bullets: int = 3

func _ready() -> void:
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
 
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -prop_scale_y
	else:
		scale.y = prop_scale_y
 
	if Input.is_action_just_pressed("fire") and not shooting and bullets > 0:
		sprite.play("shoot")
		shooting = true
		timer.start(0.0)
		bullets -= 1
		var bullet_instance = bullet.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation = rotation
 
func _on_animation_finished() -> void:
	sprite.play("default")

func _on_timer_timeout() -> void:
	shooting = false
