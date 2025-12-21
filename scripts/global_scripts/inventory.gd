extends Node

signal inventory_changed(player_id: int)
signal item_added(player_id: int, slot_index: int, item: InvItem)
signal item_removed(player_id: int, slot_index: int)

const MAX_PLAYERS := 4
const SLOTS_PER_PLAYER := 2

# inventories[player_id][slot_index]
var inventories: Array = []

const DEFAULT_PLAYER := 0

func _ready() -> void:
	_initialize()

func _initialize() -> void:
	inventories.clear()
	inventories.resize(MAX_PLAYERS)

	for i in MAX_PLAYERS:
		inventories[i] = []
		inventories[i].resize(SLOTS_PER_PLAYER)

		for j in SLOTS_PER_PLAYER:
			inventories[i][j] = null

func add_item(arg1, arg2 = null) -> bool:
	if arg2 == null:
		return _add_item_player(DEFAULT_PLAYER, arg1)
	else:
		return _add_item_player(arg1, arg2)

func _add_item_player(player_id: int, item: InvItem) -> bool:
	if not _valid_player(player_id):
		return false

	for i in range(SLOTS_PER_PLAYER):
		if inventories[player_id][i] == null:
			inventories[player_id][i] = item
			
			item_added.emit(player_id, i, item)
			inventory_changed.emit(player_id)

			return true

	return false


func remove_item(arg1, arg2 = null) -> bool:
	if arg2 == null:
		return _remove_item_player(DEFAULT_PLAYER, arg1)
	else:
		return _remove_item_player(arg1, arg2)

func _remove_item_player(player_id: int, item: InvItem) -> bool:
	if not _valid_player(player_id):
		return false

	for i in range(SLOTS_PER_PLAYER):
		if inventories[player_id][i] == item:
			inventories[player_id][i] = null

			item_removed.emit(player_id, i)
			inventory_changed.emit(player_id)

			return true

	return false


func has_item(arg1, arg2 = null) -> bool:
	if arg2 == null:
		return _has_item_player(DEFAULT_PLAYER, arg1)
	else:
		return _has_item_player(arg1, arg2)

func _has_item_player(player_id: int, item: InvItem) -> bool:
	if not _valid_player(player_id):
		return false

	return item in inventories[player_id]

func _valid_player(player_id: int) -> bool:
	return player_id >= 0 and player_id < MAX_PLAYERS
