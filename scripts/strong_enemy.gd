class_name StrongEnemy extends CharacterBody2D
@export var target: Player
var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var hit_animation: AnimationPlayer = $HitAnimation
@onready var health_bar: HealthBar = $HealthBar
@onready var hit_area: Area2D = $HitArea
enum EnemyState {
	IDLE,
	RUN,
}
var speed: int = 40
var state: EnemyState = EnemyState.IDLE
var hp: int = 100
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
@export var knockback_force : float = 150.0
@export var knockback_duration: float = 0.2
# Fear aplicado pelo livro de cálculo
@export var fear_speed_multiplier := 1.5
var is_feared := false
var fear_timer := 0.0
@onready var attack_end_timer: Timer = Timer.new()
@export var attack_recover_time := 0.15

func _ready() -> void:
	add_to_group("enemies")
	
	attack_end_timer.one_shot = true
	attack_end_timer.wait_time = attack_recover_time
	attack_end_timer.timeout.connect(_on_attack_recover_timeout)
	add_child(attack_end_timer)

	animation.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if is_feared:
		fear_timer -= delta
		if fear_timer <= 0.0:
			$StatusIcons.remove_status("fear")
			is_feared = false
		elif target:
			var away_dir := (global_position - target.global_position).normalized()
			direction = away_dir
			velocity = away_dir * speed * fear_speed_multiplier
			move_and_slide()
			return
	if target and target.is_in_group("player"):
		direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		direction = Vector2.ZERO
	
	if knockback_timer > 0.0:
		move_and_knockback(delta)
	
	if hp > 0:
		move_and_slide()

func _process(_delta: float) -> void:
	if update_direction() or update_state():
		update_animation()

func update_state() -> bool:
	var new_state : EnemyState = EnemyState.IDLE if direction == Vector2.ZERO else EnemyState.RUN
	
	if is_feared:
		new_state = EnemyState.RUN

	if new_state == state:
		return false
	
	state = new_state
	return true

func update_animation() -> void:
	var animation_state : String = "idle"
	match state:
		EnemyState.RUN:
			animation_state = "run"
	animation.play(animation_state + "_" + animation_direction())

func animation_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = null
		direction = Vector2.ZERO
		velocity = Vector2.ZERO

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
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
		
	collision_shape.position.x *= sprite.scale.x
	return true

func apply_damage(damage: int, knockback_direction: Vector2) -> void:
	AudioManager.play_enemy_hit()
	hp -= damage
	apply_knockback(
		knockback_direction, 
		knockback_force,
		knockback_duration
	)
	health_bar.update_health(hp)
	if hp <= 0:
		AudioManager.play_strong_enemy_death()
		animation.play("death")
		hit_area.set_deferred("monitoring", false)
	
func apply_knockback(specific_direction: Vector2, force: float, duration: float) -> void:
	knockback = specific_direction * force
	knockback_timer = duration

func move_and_knockback(delta: float) -> void:
	velocity = knockback
	knockback_timer -= delta
	hit_animation.play("hit_flash")
	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO
		velocity = Vector2.ZERO
		hit_animation.play("no_hit")

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_feared:
		animation.play("attack_1_" + animation_direction())
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(40, knockback_direction)	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

func apply_fear(duration: float) -> void:
	$StatusIcons.add_status("fear")
	is_feared = true
	fear_timer = duration

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
		return

	if anim_name.begins_with("attack"):
		attack_end_timer.start()

func _on_attack_recover_timeout() -> void:
	update_animation()
