extends Node2D

var player_in_area = false
signal item_collected
@export var item : InvItem
var character_id : int = 0

func _ready() -> void:
	$PickupSprite.texture = item.texture

func _unhandled_input(_event) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		if Inventory.add_item(character_id, item):
			emit_signal("item_collected")
			queue_free()

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		
func _on_character_manager_active_player_changed(player_id: int) -> void:
	character_id = player_id
