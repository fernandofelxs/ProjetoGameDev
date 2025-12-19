class_name Player extends CharacterBody2D

@export var speed : float = 100.0
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
enum PlayerState {
	IDLE,
	RUN,
	ATTACK
}
var state: PlayerState = PlayerState.IDLE
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var hit_animation: AnimationPlayer = $HitAnimation
var attacking: bool = false
@onready var flip_container: Sprite2D = $Sprite2D
@onready var attack_area : Area2D = $AttackArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var hp : int = 5
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
@export var knockback_force : float = 150.0
@export var knockback_duration: float = 0.2

func _ready() -> void:
	animation.play("idle_down")
	animation.connect("animation_finished", Callable(self, "_on_animation_finished"))
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_activated"))

func _process(_delta: float) -> void:
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_raw_strength("ui_down") - Input.get_action_strength("ui_up")
	
	velocity = direction.normalized() * speed if not attacking else Vector2.ZERO
	
	if update_direction() or update_state():
		update_animation()
	
	if Input.is_action_just_pressed("attack") and !attacking:
		attacking = true

func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		move_and_knockback(delta)
	move_and_slide()

func update_state() -> bool:
	var new_state : PlayerState = PlayerState.IDLE if direction == Vector2.ZERO else PlayerState.RUN
	
	if attacking:
		new_state = PlayerState.ATTACK
	
	if new_state == state:
		return false
	
	state = new_state
	return true

func update_animation() -> void:
	var animation_state : String = "idle"
	match state:
		PlayerState.RUN:
			animation_state = "run"
		PlayerState.ATTACK:
			animation_state = "attack"
	animation.play(animation_state + "_" + animation_direction())

func update_direction() -> bool:
	var new_direction : Vector2 = cardinal_direction
	
	if direction == Vector2.ZERO:
		return false
	
	if direction.y == 0:
		new_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_direction == cardinal_direction:
		return false
	cardinal_direction = new_direction
	flip_container.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	attack_area.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	collision_shape.position.x *= flip_container.scale.x
	return true

func animation_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func _on_animation_finished(_anim_name: String) -> void:
	if state == PlayerState.ATTACK:
		attacking = false

func _on_attack_area_activated(body: Node2D) -> void:
	if body is Enemy and attacking:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(35, knockback_direction)

func apply_damage(damage: int, knockback_direction: Vector2) -> void:
	hp -= damage
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
	hit_animation.play("hit_flash")
	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO
		hit_animation.play("no_hit")
	
# Função utilizada para detectar se um jogador entrou em uma área de colisão
func player():
	pass
