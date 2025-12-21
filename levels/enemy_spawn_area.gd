class_name EnemySpawnArea
extends Area2D

@export var enemy_scene: PackedScene
@export var spawn_cooldown := 1.0
@export var spawn_once := true

@onready var spawn_points := $SpawnPoints.get_children()

var player_inside := false
var has_spawned := false
var last_spawn_time := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not player_inside:
		return

	if spawn_once and has_spawned:
		return

	if Input.is_action_just_pressed("interact"):
		_spawn_enemies()

func _spawn_enemies() -> void:
	has_spawned = true

	for point in spawn_points:
		var enemy := enemy_scene.instantiate()
		enemy.global_position = point.global_position
		enemy.scale = Vector2(1.5, 1.5)
		get_parent().get_parent().add_child(enemy)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_inside = true

func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_inside = false
