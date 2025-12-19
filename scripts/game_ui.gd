extends Control

@onready var ui_slots: Array =  $CanvasLayer/HBoxContainer.get_children() 
var character_id : int = 0

func _ready():
	update_slots()
	
func update_slots():
	for i in range(0, ui_slots.size()):
		ui_slots[i].update(Inventory.inventories[character_id][i])

func _on_character_manager_active_player_changed(index: int) -> void:
	character_id = index
	update_slots()
