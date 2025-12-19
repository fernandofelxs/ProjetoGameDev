class_name NPC extends StaticBody2D

@onready var arrow: Sprite2D = $Arrow
@export var dialogue_lines: String = ""
@export var dialogue_box: DialogueBox = null
var player: Player = null

enum NPCState {
	READY,
	ON_SPEECH,
	NOT_READY,
	FINISHED,
}

var state: NPCState = NPCState.NOT_READY
var player_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	arrow.hide()
	dialogue_box.dialogue_finished.connect(_on_npc_dialogue_finished)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and state == NPCState.READY:
		dialogue_box.set_ref_dialogue(dialogue_lines)
		dialogue_box.show_textbox()
		state = NPCState.ON_SPEECH
		player.change_state_and_direction_forced(
			player.PlayerState.WITH_NPC,
			player_direction
		)

	if dialogue_box.is_finished() and dialogue_box.empty_dialogues():
		state = NPCState.FINISHED

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2(0, -1))
		state = NPCState.READY

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		arrow.hide()
		state = NPCState.NOT_READY
		player = null

func _on_npc_dialogue_finished() -> void:
	if state == NPCState.FINISHED:
		await get_tree().create_timer(0.3).timeout
		state = NPCState.NOT_READY
		if player:
			player.change_state_and_direction_forced(
				player.PlayerState.IDLE,
				player_direction
			)

func _on_right_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2(-1, 0))

func _on_left_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2(1, 0))

func _on_up_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2(0, 1))

func enter_on_area(body: Node2D, dir: Vector2) -> void:
	arrow.show()
	state = NPCState.READY
	player = body
	player_direction = dir
