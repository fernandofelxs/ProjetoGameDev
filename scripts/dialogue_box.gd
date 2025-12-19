class_name DialogueBox extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox: TextureRect = $TextureRect
@onready var label: Label = $TextureRect/Label
@onready var tween: Tween = null
@onready var animation: AnimationPlayer = $AnimationPlayer
@export var ref_dialogue: String = "start_dialogue"

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
			print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
	else:
		print("Failed to open dialogue file.")

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
					label.visible_ratio = 1.0
					tween.kill()
					change_state(TextBoxState.FINISHED)
			TextBoxState.FINISHED:
				if Input.is_action_just_pressed("interact"):
					change_state(TextBoxState.READY)
					if dialogues.is_empty():
						hide_textbox()

func queue_text(next_text: String) -> void:
	dialogues.push_back(next_text)

func hide_textbox() -> void:
	label.text = ""
	animation.play("exit")
	canOpenDialogue = false
	dialogue_finished.emit()

func show_textbox() -> void:
	textbox.show()
	animation.play("show")
	canOpenDialogue = true

func display_text() -> void:
	var next_text = dialogues.pop_front()
	label.text = next_text
	label.visible_ratio = 0.0
	change_state(TextBoxState.READING)
	
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, len(next_text) * CHAR_READ_RATE)
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
