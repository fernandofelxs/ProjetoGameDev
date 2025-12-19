extends Node2D

func _ready():
	$GameUI.update_slots()

func _on_item_pickup_item_collected() -> void:
	$GameUI.update_slots()
