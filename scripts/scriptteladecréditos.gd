extends ScrollContainer

@export_range(5, 10000, 0.1) var credits_time : float = 35
@export_range(0, 10000, 0.1) var margin_increment : float = 0

@onready var margin : MarginContainer = $MarginContainer
@onready var text_node : RichTextLabel = $MarginContainer/RichTextLabel
@onready var transition: Transition = $Transition

func _ready() -> void:
	# Espera layout e BBCode terminarem
	await get_tree().process_frame
	await get_tree().process_frame

	var text_height = text_node.get_content_height()
	var window_height = DisplayServer.window_get_size().y

	# Margens para começar fora da tela
	margin.add_theme_constant_override(
		"margin_top",
		window_height + margin_increment
	)
	margin.add_theme_constant_override(
		"margin_bottom",
		window_height + margin_increment
	)

	var scroll_amount := int(
		text_height + window_height * 2 + margin_increment
	)

	var tween := create_tween()
	tween.tween_property(
		self,
		"scroll_vertical",
		scroll_amount,
		credits_time
	)

	tween.finished.connect(_acabou)

func _acabou() -> void:
	transition.change_scene("main_menu")
