class_name Player extends CharacterBody2D

@export var speed : float = 100.0
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
enum PlayerState {
	IDLE,
	RUN,
	ATTACK,
	WITH_NPC,
	DEATH
}
var state: PlayerState = PlayerState.IDLE
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var hit_animation: AnimationPlayer = $HitAnimation
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area : Area2D = $AttackArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var hp : int = 100
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
@export var knockback_force : float = 150.0
@export var knockback_duration: float = 0.2
signal player_damaged(hp: int)
enum PlayerMode {
	ATTACK,
	GUN
}
@export var id: int = 1
var player_mode: PlayerMode = PlayerMode.ATTACK
@onready var gun: Gun = $Gun
var is_active: bool = true # Is he the current player?
@onready var flashlight: Flashlight = $Flashlight
@export var can_switch: bool = false
var aim = load("res://assets/sprites/ui/aim-1.png")
var cursor = load("res://assets/sprites/ui/Cursor.png")
@onready var dust_position: Marker2D = $DustPosition
@export var boss_mode: bool = false
@onready var pointlight: PointLight2D = $PointLight2D
@export var screenshake: Screenshake = null

const DUST_SCENE: PackedScene = preload("res://scenes/others/dust.tscn")

signal switch_mode
signal player_dead

func activate_boss_mode() -> void:
	pointlight.hide()
	flashlight.hide()
	flashlight.set_process(false)
	gun.hide()
	gun.set_process(false)

func _ready() -> void:
	if boss_mode:
		activate_boss_mode()
	
	sprite.material = sprite.material.duplicate()
	animation.play("idle_down")
	
	animation.connect("animation_finished", Callable(self, "_on_animation_finished"))
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_activated"))
	
	player_mode = PlayerMode.ATTACK
	gun.set_process(false)
	gun.hide()
	update_texture("")
	
func update_texture(condition: String) -> void:
	sprite.texture = load("res://assets/sprites/player/player_" + str(id) + condition + "_sprite_sheet.png")

func spawn_dust() -> void:
	var dust: Node = DUST_SCENE.instantiate()
	dust.position = dust_position.global_position
	get_parent().add_child(dust)

func _process(_delta: float) -> void:
	if is_active and state != PlayerState.WITH_NPC and state != PlayerState.DEATH:
		if state != PlayerState.ATTACK:
			direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		flashlight.set_process(true)
		if Input.is_action_just_pressed("fire") and player_mode == PlayerMode.ATTACK and not state == PlayerState.ATTACK:
			AudioManager.play_attack()
			state = PlayerState.ATTACK
		
		if Input.is_action_just_pressed("switch_weapon") and can_switch:
			switch_player_mode()
			
		velocity = direction.normalized() * speed if not state == PlayerState.ATTACK else Vector2.ZERO
		
		if update_direction() or update_state():
			update_animation()
		
		if Input.is_action_just_pressed("switch_player_character"):
			player_mode = PlayerMode.GUN
			switch_player_mode()
	else:
		state = PlayerState.IDLE
		update_animation()
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
		flashlight.set_process(false)
		gun.set_process(false)

func can_attack() -> bool:
	return player_mode == PlayerMode.ATTACK and not state == PlayerState.ATTACK

func switch_player_mode() -> void:
	match player_mode:
		PlayerMode.ATTACK:
			player_mode = PlayerMode.GUN
			gun.set_process(true)
			gun.show()
			update_texture("without_hands")
			flashlight.hide()
			Input.set_custom_mouse_cursor(aim)
		PlayerMode.GUN:
			player_mode = PlayerMode.ATTACK
			gun.set_process(false)
			gun.hide()
			update_texture("")
			flashlight.show()
			Input.set_custom_mouse_cursor(cursor)
	switch_mode.emit()

func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		move_and_knockback(delta)
	
	if state != PlayerState.DEATH and state != PlayerState.WITH_NPC:
		move_and_slide()

	update_walk_sound()

func update_state() -> bool:
	if state == PlayerState.WITH_NPC or state == PlayerState.DEATH or state == PlayerState.ATTACK:
		return true
	
	var new_state : PlayerState = PlayerState.IDLE if direction == Vector2.ZERO else PlayerState.RUN
	
	if new_state == state:
		return false
	
	state = new_state
	return true

func change_state_and_direction_forced(new_state: PlayerState, new_direction: Vector2) -> void:
	cardinal_direction = new_direction
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
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
		PlayerState.DEATH:
			animation_state = "death"
	animation.play(animation_state + "_" + animation_direction())

func update_direction() -> bool:
	var new_direction : Vector2 = cardinal_direction
	
	if direction == Vector2.ZERO:
		return false
	
	if direction.y == 0:
		new_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if direction.y != 0 and direction.x != 0:
		new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_direction == cardinal_direction:
		return false
	
	cardinal_direction = new_direction
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	attack_area.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	collision_shape.position.x *= sprite.scale.x
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
		state = PlayerState.IDLE
		update_animation()

func _on_attack_area_activated(body: Node2D) -> void:
	if (body is Enemy or body is BaseEnemy) and state == PlayerState.ATTACK:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_damage(35, knockback_direction)

func apply_damage(damage: int, knockback_direction: Vector2) -> void:
	AudioManager.play_damage()
	hp -= damage
	apply_knockback(
		knockback_direction, 
		knockback_force,
		knockback_duration
	)
	player_damaged.emit(hp)
	
	if screenshake:
		screenshake.apply_shake()

	if hp <= 0:
		death()

func death() -> void:
	AudioManager.stop_walk()
	player_dead.emit()
	var direction_death: Vector2 = Vector2.LEFT if cardinal_direction.x < 0 else Vector2.RIGHT
	gun.hide()
	flashlight.hide()
	hit_animation.play("no_hit")
	remove_from_group("player")
	change_state_and_direction_forced(
		PlayerState.DEATH,
		direction_death
	)
	set_process(false)
	set_physics_process(false)
	
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

func get_gun_bullets() -> int:
	return gun.bullets

func add_bullets(quantity: int) -> void:
	gun.bullets += quantity

func is_gun_mode() -> bool:
	return player_mode == PlayerMode.GUN

func update_walk_sound() -> void:
	if not is_active:
		return
	if velocity.length() > 0.0 and knockback_timer <= 0.0:
		AudioManager.start_walk()
	else:
		AudioManager.stop_walk()
