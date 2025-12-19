extends Control

@onready var ui_slots: Array =  $CanvasLayer/VBoxContainer/HBoxContainer.get_children() 
@onready var player_health_bar: HealthBar = $CanvasLayer/VBoxContainer/PlayerHealth/HealthBar
var character_id : int = 0

func _ready():
	update_slots()
	
func update_slots():
	for i in range(0, ui_slots.size()):
		ui_slots[i].update(Inventory.inventories[character_id][i])

func _on_character_manager_active_player_changed(index: int, player: Player) -> void:
	character_id = index
	call_deferred("_apply_player_ui", player)

func _apply_player_ui(player: Player) -> void:
	player_health_bar.update_health(player.hp)
	update_slots()

func _on_player_player_damaged(hp: int) -> void:
	player_health_bar.update_health(hp)
	update_slots()
