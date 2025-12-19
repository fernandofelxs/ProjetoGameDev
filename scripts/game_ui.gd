extends Control

@onready var ui_slots: Array =  $CanvasLayer/HBoxContainer.get_children() 

func _ready():
	update_slots()
	
func update_slots():
	for i in range(min(Inventory.slots.size(), ui_slots.size())):
		ui_slots[i].update(Inventory.slots[i])
