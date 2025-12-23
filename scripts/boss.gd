class_name Boss
extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

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
var factor_flip: float = 1.6
@onready var hit_animation: AnimationPlayer = $HitAnimation

enum BossState {
	IDLE,
	RUN,
	DAMAGE,
	DEATH
}

signal boss_dead

var state: BossState = BossState.IDLE

func _ready() -> void:
	factor_flip = sprite.scale.x
	timer.timeout.connect(_on_timeout)

	if check_should_movement():
		make_path()

func _physics_process(delta: float) -> void:
	if state != BossState.DEATH:
		if knockback_timer > 0.0:
			move_and_knockback(delta)
		else:
			update_movement()
		
		move_and_slide()

func _process(_delta: float) -> void:
	if update_state() and state != BossState.DEATH:
		update_animation()

func update_state() -> bool:
	if state == BossState.DEATH or state == BossState.DAMAGE:
		return true
	
	var new_state: BossState = BossState.IDLE
	
	if velocity != Vector2.ZERO:
		new_state = BossState.RUN
	
	if new_state != state:
		state = new_state
		return true
	
	return false

func update_animation() -> void:
	var animation_start: String = "idle"
	match state:
		BossState.RUN:
			animation_start = "run"
		BossState.DEATH:
			animation_start = "death"
		BossState.DAMAGE:
			animation_start = "damage"
	sprite.play(animation_start)

func update_movement() -> void:
	if check_should_movement():
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
	else:
		velocity = Vector2.ZERO

func update_facing() -> void:
	if velocity.x == 0:
		return

	sprite.scale.x = -factor_flip if velocity.x < 0 else factor_flip

func check_should_movement():
	return player and player.is_in_group("player") and not state == BossState.DAMAGE and not state == BossState.DEATH

func make_path() -> void:
	if navigation.target_position != player.global_position and check_should_movement():
		navigation.target_position = player.global_position

func _on_timeout() -> void:
	if check_should_movement():
		make_path()

func apply_damage(damage: int, knockback_direction: Vector2) -> void:
	AudioManager.play_enemy_hit()
	
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
		state = BossState.DEATH
		sprite.play("death")
		boss_dead.emit()

func apply_knockback(knockback_direction: Vector2, force: float, duration: float) -> void:
	knockback = knockback_direction * force
	knockback_timer = duration
	knockbacking = true
	state = BossState.DAMAGE

func move_and_knockback(delta: float) -> void:
	velocity = knockback
	knockback_timer -= delta
	hit_animation.play("hit_flash")
	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO
		knockbacking = false
		state = BossState.IDLE
		hit_animation.play("no_hit")

func _on_area_activated(body: Node2D) -> void:
	if body is Player:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(20, knockback_direction)
