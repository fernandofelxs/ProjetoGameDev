extends Node2D

@export var players: Array[Player] = []
@export var camera_speed := 100.0

@onready var camera: Camera2D = $Camera2D

signal active_player_changed(player_id: int, player_char: Player)

var current_index := 0

func _ready() -> void:
	if players.is_empty():
		return

	_activate_player(0)

func _physics_process(delta: float) -> void:
	if players.is_empty():
		return

	var target_pos := players[current_index].global_position
	var step := camera_speed * delta

	camera.global_position = camera.global_position.move_toward(
		target_pos,
		step
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_player_character"):
		switch_player_character()

func switch_player_character() -> void:
	players[current_index].is_active = false
	current_index = (current_index + 1) % players.size()
	_activate_player(current_index)

func _activate_player(index: int) -> void:
	for i in players.size():
		players[i].is_active = (i == index)
	active_player_changed.emit(index, players[index])

	camera_speed = players[index].speed
	camera.global_position = players[index].global_position

func get_active_player_id() -> int:
	return current_index
