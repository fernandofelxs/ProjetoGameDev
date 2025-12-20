# A GameUi deve estar na mesma cena que o CharacterManager

class_name GameUI extends CanvasLayer

@onready var ui_slots: Array =  $VBoxContainer/HBoxContainer.get_children() 
@onready var player_health_bar: HealthBar = $VBoxContainer/PlayerHealth/HealthBar
var character_id : int = 0
var character_manager: CharacterManager

func _ready():
	Inventory.inventory_changed.connect(_on_inventory_changed)
	character_manager = get_tree().get_first_node_in_group("character_manager")
	if not character_manager:
		push_error("CharacterManager not found")
		return

	character_manager.active_player_changed.connect(
		_on_character_manager_active_player_changed
	)
	
func update_slots():
	for i in range(0, ui_slots.size()):
		ui_slots[i].update(Inventory.inventories[character_id][i])

func _on_character_manager_active_player_changed(index: int, player: Player) -> void:
	character_id = index
	call_deferred("_apply_player_ui", player)

func _apply_player_ui(player: Player) -> void:
	player_health_bar.update_health(player.hp)
	update_slots()

func _on_inventory_changed(player_id: int) -> void:
	if player_id != character_id:
		return
	update_slots()
