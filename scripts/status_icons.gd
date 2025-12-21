class_name StatusIcons
extends Node2D

@onready var container: HBoxContainer = $HBoxContainer

# Statuses: "fear"
var active_statuses: Dictionary = {}

func _ready() -> void:
	_hide_all_icons()

func add_status(status_name: String) -> void:
	active_statuses[status_name] = true
	_update_icons()

func remove_status(status_name: String) -> void:
	active_statuses.erase(status_name)
	_update_icons()

func clear_statuses() -> void:
	active_statuses.clear()
	_update_icons()

func has_status(status_name: String) -> bool:
	return active_statuses.has(status_name)

func _update_icons() -> void:
	for icon in container.get_children():
		if not icon is TextureRect:
			continue

		icon.visible = active_statuses.has(icon.name)

func _hide_all_icons() -> void:
	for icon in container.get_children():
		if icon is TextureRect:
			icon.visible = false
