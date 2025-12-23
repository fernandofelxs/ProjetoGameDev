class_name DialogueBox extends CanvasLayer

const CHAR_READ_RATE = 0.5

@onready var textbox: TextureRect = $TextureRect
@onready var text_label: Label = $TextureRect/Text
@onready var name_label: Label = $TextureRect/Name
@onready var tween: Tween = null
@onready var camera_tween: Tween = null
@onready var animation: AnimationPlayer = $AnimationPlayer
@export var ref_dialogue: String = "start_dialogue"
@export var camera: Camera2D = null

signal dialogue_finished

enum TextBoxState {
	OPENED,
	READY,
	READING,
	FINISHED
}

var current_state: TextBoxState = TextBoxState.OPENED
var dialogues: Array = []
@export var dialogue_file_path: String = "res://assets/dialog/dialogues.json"
var canOpenDialogue: bool = false
var camera_original_zoom: Vector2 = Vector2.ZERO
var camera_original_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	text_label.visible_ratio = 0.0
	if camera:
		camera_original_offset = camera.offset
		camera_original_zoom = camera.zoom
	

func load_dialogue_data():
	var file = FileAccess.open(dialogue_file_path, FileAccess.READ)
	if file.is_open():
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			dialogues = json.data[ref_dialogue]
		else:
			push_error("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
	else:
		push_error("Failed to open dialogue file.")

func _process(_delta) -> void:
	if canOpenDialogue:
		match current_state:
			TextBoxState.OPENED:
				show_textbox()
				change_state(TextBoxState.READY)
			TextBoxState.READY:	
				if !dialogues.is_empty():
					display_text()
			TextBoxState.READING:
				if Input.is_action_just_pressed("interact"):
					text_label.visible_ratio = 1.0
					tween.kill()
					change_state(TextBoxState.FINISHED)
			TextBoxState.FINISHED:
				if Input.is_action_just_pressed("interact"):
					change_state(TextBoxState.READY)
					if dialogues.is_empty():
						hide_textbox()

func camera_zoom(duration: float) -> void:
	camera_tween = create_tween()
	camera_tween.tween_property(camera, "zoom", Vector2(7, 7), duration)
	camera_tween.parallel().tween_property(camera, "offset", Vector2(0, 17), duration)
	camera_tween.play()

func camera_return_zoom(duration: float) -> void:
	camera_tween = create_tween()
	camera_tween.tween_property(camera, "zoom", camera_original_zoom, duration)
	camera_tween.parallel().tween_property(camera, "offset", camera_original_offset, duration)
	camera_tween.play()	

func queue_text(next_text: String) -> void:
	dialogues.push_back(next_text)

func hide_textbox() -> void:
	camera_return_zoom(0.5)
	text_label.text = ""
	animation.play("exit")
	canOpenDialogue = false
	dialogue_finished.emit()

func show_textbox() -> void:
	camera_zoom(0.5)
	textbox.show()
	animation.play("show")
	canOpenDialogue = true

func display_text() -> void:
	var next_text = dialogues.pop_front()
	name_label.text = next_text["name"].to_upper()
	text_label.text = next_text["text"]
	text_label.visible_ratio = 0.0
	change_state(TextBoxState.READING)
	
	tween = create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, len(next_text) * CHAR_READ_RATE)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", _on_tween_finished)
	tween.play()

func change_state(next_state: TextBoxState) -> void:
	current_state = next_state

func _on_tween_finished() -> void:
	change_state(TextBoxState.FINISHED)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "exit":
		textbox.hide()

func set_ref_dialogue(new_ref_dialogue: String) -> void:
	ref_dialogue = new_ref_dialogue
	load_dialogue_data()

func empty_dialogues() -> bool:
	return dialogues.is_empty()

func is_finished() -> bool:
	return current_state == TextBoxState.FINISHED
