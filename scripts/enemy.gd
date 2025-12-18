class_name Enemy extends CharacterBody2D

var direction : Vector2 = Vector2.ZERO
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hp : int = 3
var cardinal_direction : Vector2 = Vector2.DOWN
@export var speed : float = 50
@export var player: Player
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
enum EnemyState {
	IDLE,
	RUN,
}
var state: EnemyState = EnemyState.IDLE
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.connect("timeout", _on_timeout)
	sprite.play("idle_down")
	make_path()
	
func _physics_process(_delta: float) -> void:
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
	sprite.play(animation_state + "_" + animation_direction())

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
