# O character manager deve estar na mesma cena que um elemento GameUI

class_name CharacterManager
extends Node2D

@export var players: Array[Player] = []
@export var camera_speed := 100.0

@onready var camera: Camera2D = $Camera2D

signal active_player_changed(player_id: int, player_char: Player)

var current_index := 0

func _ready() -> void:
	add_to_group("character_manager")
	
	if players.is_empty():
		return

	# conectar sinais dos jogadores e dos itens
	for i in players.size():
		var player := players[i]
		player.player_damaged.connect(
			_on_player_damaged.bind(i)
		)
	_connect_item_pickups()

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
		
	if event.is_action_pressed("special_1"):
		use_item_at_slot(0)

	if event.is_action_pressed("special_2"):
		use_item_at_slot(1)


func switch_player_character() -> void:
	players[current_index].is_active = false
	current_index = (current_index + 1) % players.size()
	_activate_player(current_index)

func _activate_player(index: int) -> void:
	for i in players.size():
		players[i].is_active = (i == index)
	active_player_changed.emit(index, players[index])

	camera_speed = players[index].speed
	var tween = create_tween()
	tween.tween_property(camera, "global_position", players[index].global_position, 1)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	
func get_active_player_id() -> int:
	return current_index

func _on_player_damaged(_hp: int, player_id: int) -> void:
	if player_id != current_index:
		return

	# Re-emit active player info (for HUD, UI, etc.)
	active_player_changed.emit(
		current_index,
		players[current_index]
	)

func _connect_item_pickups() -> void:
	var pickups := get_tree().get_nodes_in_group("item_pickups")

	for pickup in pickups:
		if pickup is ItemPickup:
			pickup.item_collected.connect(
				_on_item_collected.bind(pickup)
			)

func _on_item_collected():
	active_player_changed.emit(
		current_index,
		players[current_index]
	)

func use_item_at_slot(slot_index: int) -> void:
	var player_id := current_index
	var player := players[player_id]

	# Safety
	if slot_index < 0 or slot_index >= Inventory.SLOTS_PER_PLAYER:
		return

	var item : InvItem = Inventory.inventories[player_id][slot_index]
	if item == null:
		return

	match item.name:
		"CalculusBook":
			_apply_fear_aoe(player, 110.0, 3.0)
			Inventory.remove_item(player_id, item)
		"Medkit":
			if player.hp < 100:
				player.hp = 100
				Inventory.remove_item(player_id, item)
		"Keys":
			if _try_open_nearby_door(player):
				Inventory.remove_item(player_id, item)

	active_player_changed.emit(player_id, player)

func _apply_fear_aoe(player: Player, radius: float, duration: float) -> void:
	var origin := player.global_position

	var fear_circle := Node2D.new()
	fear_circle.set_script(load("res://scripts/fear_circle.gd"))
	fear_circle.global_position = origin
	fear_circle.max_radius = radius
	player.get_parent().get_parent().add_child(fear_circle)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.has_method("apply_fear"):
			continue

		if enemy.global_position.distance_to(origin) <= radius:
			enemy.apply_fear(duration)

func _try_open_nearby_door(player: Player) -> bool:
	for door in get_tree().get_nodes_in_group("doors"):
		if door is Door:
			if door.try_open_with_key():
				return true
	return false
