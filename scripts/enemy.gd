class_name Enemy extends CharacterBody2D

var direction : Vector2 = Vector2.ZERO
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@export var hp : int = 100
var cardinal_direction : Vector2 = Vector2.DOWN
@export var speed : float = 50
@export var player: Player
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
enum EnemyState {
	IDLE,
	RUN,
	DAMAGE
}
var state: EnemyState = EnemyState.IDLE
@onready var timer: Timer = $Timer
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
@export var knockback_force : float = 150.0
@export var knockback_duration: float = 0.2
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D
var knockbacking: bool = false
@onready var health_bar: HealthBar = $HealthBar

func _ready() -> void:
	timer.connect("timeout", _on_timeout)
	sprite.play("idle_down")
	area.connect("body_entered", Callable(self, "_on_area_activated"))
	animation.connect("animation_finished", Callable(self, "_on_animation_finished"))
	make_path()
	
func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		move_and_knockback(delta)
	
	if hp > 0:
		move_and_slide()
	
func _process(_delta: float) -> void:
	if not navigation.is_target_reached():
		direction = to_local(navigation.get_next_path_position())
		velocity = direction.normalized() * speed
	
	if update_direction() or update_state():
		update_animation()

func make_path() -> void:
	if navigation.target_position != player.global_position:
		navigation.target_position = player.global_position

func update_state() -> bool:
	var new_state : EnemyState = EnemyState.IDLE if direction == Vector2.ZERO else EnemyState.RUN
	
	if knockbacking:
		new_state = EnemyState.DAMAGE
	
	if new_state == state:
		return false
	
	state = new_state
	return true

func _on_timeout() -> void:
	make_path()

func update_animation() -> void:
	var animation_state : String = "idle"
	match state:
		EnemyState.RUN:
			animation_state = "run"
		EnemyState.DAMAGE:
			animation_state = "damage"
	sprite.play(animation_state + "_" + animation_direction())

func update_direction() -> bool:
	var new_direction : Vector2 = cardinal_direction
	
	if direction == Vector2.ZERO:
		return false
	
	var angle: float = direction.angle()
	
	if new_direction == cardinal_direction:
		return false
	cardinal_direction = new_direction
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func animation_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func apply_damage(damage: int, knockback_direction: Vector2) -> void:
	hp -= damage
	health_bar.update_health(hp)
	apply_knockback(
		knockback_direction, 
		knockback_force,
		knockback_duration
	)
	
func apply_knockback(specific_direction: Vector2, force: float, duration: float) -> void:
	knockback = specific_direction * force
	knockback_timer = duration

func move_and_knockback(delta: float) -> void:
	velocity = knockback
	knockback_timer -= delta
	animation.play("hit_flash")
	knockbacking = true

	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO
		animation.play("no_flash")
		knockbacking = false

	if hp <= 0:
		animation.play("death")

func _on_area_activated(body: Node2D) -> void:
	if body is Player:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(10, knockback_direction)		

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		queue_free()
