extends Node2D

func _ready() -> void:
	$GameUI.update_slots()

func _on_item_pickup_item_collected():
	$GameUI.update_slots()
