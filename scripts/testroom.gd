extends Node2D

func _ready() -> void:
	$GameUI.update_slots()

	for pickup in get_tree().get_nodes_in_group("item_pickups"):
		pickup.item_collected.connect(_on_item_pickup_item_collected)

func _on_item_pickup_item_collected():
	$GameUI.update_slots()
