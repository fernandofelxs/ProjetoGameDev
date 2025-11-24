class_name Enemy extends CharacterBody2D

var direction : Vector2 = Vector2.ZERO
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hp : int = 3
var cardinal_direction : Vector2 = Vector2.DOWN
@export var move_speed : float = 100.0
var player: Player = null
@onready var detection_area : Area2D = $Area2D
var state: EnemyState = EnemyState.IDLE
enum EnemyState {
	IDLE,
	RUN,
}

func _ready() -> void:
	detection_area.connect("body_entered", _on_detection_area_entered)
	detection_area.connect("body_exited", _on_detection_area_exited)
	sprite.play("idle_down")
	
func _physics_process(_delta: float) -> void:
	move_and_slide()

func _process(_delta: float) -> void:
	if player:
		direction = player.direction
		velocity = direction * move_speed	

func update_state() -> bool:
	var new_state : EnemyState = EnemyState.IDLE if direction == Vector2.ZERO else EnemyState.RUN
	
	if new_state == state:
		return false
	state = new_state
	return true

func _on_detection_area_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		state = EnemyState.RUN

func _on_detection_area_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		state = EnemyState.IDLE	
