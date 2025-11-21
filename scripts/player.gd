class_name Player extends CharacterBody2D

var move_speed : float = 100.0
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
enum PlayerState {
	IDLE,
	RUN,
	ATTACK
}
var state: PlayerState = PlayerState.IDLE
@onready var animation: AnimationPlayer = $AnimationPlayer
var attacking: bool = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	animation.play("idle_down")
	animation.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _process(_delta: float) -> void:
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_raw_strength("ui_down") - Input.get_action_strength("ui_up")
	
	velocity = direction * move_speed
	
	if update_direction() || update_state():
		update_animation()
	
	if Input.get_action_raw_strength("attack") and !attacking:
		attacking = true

func _physics_process(_delta: float) -> void:
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
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func animation_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func _on_animation_finished(_anim_name: String):
	if state == PlayerState.ATTACK:
		attacking = false
