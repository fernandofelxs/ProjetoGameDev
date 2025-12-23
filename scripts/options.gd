class_name Options extends CanvasLayer

@onready var fullscreen_checkbox: CheckBox = $FullscreenCheckBox
@onready var volume_slider: Slider = $VolumeSlider
@onready var transition: Transition = $Transition
@onready var audio_bus_id = AudioServer.get_bus_index("Master")
@onready var percentage_label: Label = $PercentageLabel

var is_paused_mode: bool = false

signal options_exited

func _ready() -> void:
	var volume_bus: float = AudioServer.get_bus_volume_db(audio_bus_id)
	volume_slider.value = volume_bus
	update_percentage(volume_bus)

func update_percentage(volume_bus: float) -> void:
	var percentage: String = str(round(volume_bus)) + "%"
	percentage_label.text = percentage
	
func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed() -> void:
	AudioManager.play_ui_click()
	if is_paused_mode:
		transition.play_fade_in()
		await transition.animation.animation_finished
		options_exited.emit()
		queue_free()
	else:
		transition.change_scene("main_menu")

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_bus_id, value)
	update_percentage(AudioServer.get_bus_index("Master"))
