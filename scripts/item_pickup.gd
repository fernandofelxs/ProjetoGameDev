extends Node2D

var player_in_area := false
signal item_collected
@export var item : InvItem
var player_id : int

@onready var character_manager := get_node("../CharacterManager")

func _ready() -> void:
	$PickupSprite.texture = item.texture

func _unhandled_input(_event) -> void:
	if not player_in_area:
		return

	if Input.is_action_just_pressed("interact"):
		var player_id = character_manager.get_active_player_id()

		if Inventory.add_item(player_id, item):
			item_collected.emit()
			queue_free()

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
