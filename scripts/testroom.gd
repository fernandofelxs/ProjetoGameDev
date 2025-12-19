extends Node2D

@onready var game_ui: Control = $CanvasLayer/GameUI

func _ready():
	Inventory.slots[1] = preload("res://inventory/items/CalculusBook.tres")
	game_ui.update_slots()

func _on_item_pickup_item_collected() -> void:
	game_ui.update_slots()
