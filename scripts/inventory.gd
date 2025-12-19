extends Node

var slots := [null, null]  # dois slots por personagem

func add_item(item: InvItem) -> bool:
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = item
			return true
	return false  # inventário cheio

func remove_item(item: InvItem) -> bool:
	for i in range(slots.size()):
		if slots[i] == item:
			slots[i] = null
			return true
	return false

func has_item(item: InvItem) -> bool:
	return item in slots
