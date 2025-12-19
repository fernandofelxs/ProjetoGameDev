class_name Boss
extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
@onready var sprite: Sprite2D = $Sprite2D

@export var target_scene_name: String
@export var hp: int = 100
@export var speed: float = 50
@export var player: Player

@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D
@onready var health_bar: HealthBar = $HealthBar

# Knockback
var knockback: Vector2 = Vector2.ZERO
var knockback_timer := 0.0
@export var knockback_force := 150.0
@export var knockback_duration := 0.2
var knockbacking := false

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	area.body_entered.connect(_on_area_activated)
	make_path()

func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		move_and_knockback(delta)
	else:
		update_movement()

	move_and_slide()

func update_movement() -> void:
	navigation.target_position = player.global_position

	if navigation.is_target_reached():
		velocity = Vector2.ZERO
		return

	var next_pos := navigation.get_next_path_position()

	var move_dir := (next_pos - global_position)

	if move_dir.length_squared() == 0:
		velocity = Vector2.ZERO
		return

	velocity = move_dir.normalized() * speed
	update_facing()


func update_facing() -> void:
	if velocity.x == 0:
		return

	sprite.scale.x = -1 if velocity.x < 0 else 1

func make_path() -> void:
	if navigation.target_position != player.global_position:
		navigation.target_position = player.global_position

func _on_timeout() -> void:
	make_path()

func apply_damage(damage: int, knockback_direction: Vector2) -> void:
	if knockback_timer > 0.0:
		return
	
	hp -= damage
	health_bar.update_health(hp)

	apply_knockback(
		knockback_direction,
		knockback_force,
		knockback_duration
	)

	if hp <= 0:
		queue_free()
		var transition = $"../Transition"
		if transition:
			transition.change_scene(target_scene_name)
		else:
			push_error("Transition node not found!")

func apply_knockback(knockback_direction: Vector2, force: float, duration: float) -> void:
	knockback = knockback_direction * force
	knockback_timer = duration
	knockbacking = true

func move_and_knockback(delta: float) -> void:
	velocity = knockback
	knockback_timer -= delta

	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO
		knockbacking = false

func _on_area_activated(body: Node2D) -> void:
	if body is Player:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(1, knockback_direction)
