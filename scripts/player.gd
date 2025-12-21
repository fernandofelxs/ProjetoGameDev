class_name Player extends CharacterBody2D

@export var speed : float = 100.0
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
enum PlayerState {
	IDLE,
	RUN,
	ATTACK,
	WITH_NPC
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
@export var is_active = true
signal player_damaged(hp: int)
enum PlayerMode {
	ATTACK,
	GUN
}
var player_mode: PlayerMode = PlayerMode.ATTACK
@onready var gun: Gun = $Gun

func _ready() -> void:
	animation.play("idle_down")
	animation.connect("animation_finished", Callable(self, "_on_animation_finished"))
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_activated"))
	player_mode = PlayerMode.ATTACK
	gun.set_process(false)
	gun.hide()
	
func _process(_delta: float) -> void:
	if is_active and state != PlayerState.WITH_NPC:
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

		if Input.is_action_just_pressed("attack") and not attacking and player_mode == PlayerMode.ATTACK:
			attacking = true
		
		if Input.is_action_just_pressed("switch_weapon"):
			match player_mode:
				PlayerMode.ATTACK:
					player_mode = PlayerMode.GUN
					gun.set_process(true)
					gun.show()
				PlayerMode.GUN:
					player_mode = PlayerMode.ATTACK
					gun.set_process(false)
					gun.hide()
	else:
		direction = Vector2.ZERO

	velocity = direction.normalized() * speed if (is_active and not attacking and state != PlayerState.WITH_NPC) else Vector2.ZERO

	if update_direction() or update_state():
		update_animation()


func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		move_and_knockback(delta)
	move_and_slide()

func update_state() -> bool:
	if state == PlayerState.WITH_NPC:
		return false
	
	var new_state : PlayerState = PlayerState.IDLE if direction == Vector2.ZERO else PlayerState.RUN
	
	if attacking:
		new_state = PlayerState.ATTACK
	
	if new_state == state:
		return false
	
	state = new_state
	return true

func change_state_and_direction_forced(new_state: PlayerState, new_direction: Vector2) -> void:
	cardinal_direction = new_direction
	update_direction()
	state = new_state
	update_animation()

func update_animation() -> void:
	var animation_state : String = "idle"
	match state:
		PlayerState.RUN:
			animation_state = "run"
		PlayerState.ATTACK:
			animation_state = "attack"
		PlayerState.WITH_NPC:
			animation_state = "idle"
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
	if (body is Enemy or body is BaseEnemy) and attacking:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(35, knockback_direction)

func apply_damage(damage: int, knockback_direction: Vector2) -> void:
	hp -= damage
	apply_knockback(
		knockback_direction, 
		knockback_force,
		knockback_duration
	)
	player_damaged.emit(hp)
	
	if hp <= 0:
		pass
	
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
