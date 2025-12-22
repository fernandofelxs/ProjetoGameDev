# A GameUi deve estar na mesma cena que o CharacterManager

class_name GameUI extends CanvasLayer

@onready var ui_slots: Array =  $VBoxContainer/HBoxContainer.get_children() 
@onready var player_health_bar: HealthBar = $VBoxContainer/PlayerHealth/HealthBar
@onready var character_container: HBoxContainer = $CharacterContainer
var character_id : int = 0
var character_manager: CharacterManager
var bullets: int = 0
@onready var bullet_system: Control = $BulletSystem
@onready var bullet_label: Label = $BulletSystem/BulletLabel
var player_can_shoot: Player = null

func _ready():
	show()
	Inventory.inventory_changed.connect(_on_inventory_changed)
	character_manager = get_tree().get_first_node_in_group("character_manager")
	if not character_manager:
		push_error("CharacterManager not found")
		return

	character_manager.active_player_changed.connect(
		_on_character_manager_active_player_changed
	)
	
	var size: int = len(character_manager.players)
	var font_data = load("res://assets/fonts/VCR_OSD_MONO_1.001.ttf")
	
	for i in range(size):
		var label = Label.new()
		label.text = str(i + 1)
		label.add_theme_font_size_override("font_size", 80)
		label.add_theme_font_override("font", font_data)
		character_container.add_child(label)
	
	update_character_container()
	bullet_system.hide()
	
	for player in character_manager.players:
		if player.can_switch: # Only one player can get the gun.
			player_can_shoot = player		
			break
	
	if player_can_shoot:		
		update_bullets()
		player_can_shoot.connect("switch_mode", Callable(self, "_on_switch_mode"))
		player_can_shoot.gun.connect("gun_shoot", Callable(self, "_on_gun_shoot"))

func update_bullets() -> void:
	bullet_label.text = str(player_can_shoot.get_gun_bullets())

func _on_gun_shoot() -> void:
	update_bullets()

func _on_switch_mode() -> void:
	if player_can_shoot.is_gun_mode():
		update_bullets()
		bullet_system.show()
	else:
		bullet_system.hide()

func update_character_container() -> void:
	var labels: Array[Node] = character_container.get_children()
	for i in range(len(labels)):
		if i == character_id:
			labels[i].add_theme_color_override("font_color", Color(1, 0, 0))
		else:
			labels[i].add_theme_color_override("font_color", Color(255, 255, 255))

func update_slots():
	for i in range(0, ui_slots.size()):
		ui_slots[i].update(Inventory.inventories[character_id][i])

func _on_character_manager_active_player_changed(index: int, player: Player) -> void:
	character_id = index
	call_deferred("_apply_player_ui", player)

func _apply_player_ui(player: Player) -> void:
	player_health_bar.update_health(player.hp)
	bullet_system.hide()
	update_character_container()
	update_slots()

func _on_inventory_changed(player_id: int) -> void:
	if player_id != character_id:
		return
	update_slots()
