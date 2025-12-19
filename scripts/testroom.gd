extends Node2D

func _ready():
	Inventory.slots[1] = preload("res://inventory/items/CalculusBook.tres")
	$GameUI.update_slots()
