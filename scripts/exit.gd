class_name Exit extends StaticBody2D

@onready var arrow: Sprite2D = $Arrow
@export var dialogue_lines: String = ""
@export var dialogue_box: DialogueBox = null
@export var target_scene_name: String
var player: Player = null
var cardinal_direction: Vector2 = Vector2.DOWN

enum NPCState {
	READY,
	ON_SPEECH,
	NOT_READY,
	FINISHED,
}

var state: NPCState = NPCState.NOT_READY
var new_player_direction: Vector2 = Vector2.ZERO
var old_player_direction: Vector2 = Vector2.ZERO
@onready var focus_area: Area2D = $Down
var factor_flip: int = 1
var has_pong = false

func _ready() -> void:
	arrow.hide()
	update_animation()
	dialogue_box.dialogue_finished.connect(_on_npc_dialogue_finished)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and state == NPCState.READY:
		if has_pong:
			var transition = $"../Transition"
			if transition:
				transition.change_scene(target_scene_name)
		else:				
			arrow.hide()
			update_animation()
			player.change_state_and_direction_forced(
				player.PlayerState.WITH_NPC,
				new_player_direction
			)
			dialogue_box.set_ref_dialogue(dialogue_lines)
			dialogue_box.show_textbox()
			state = NPCState.ON_SPEECH
	
	if not has_pong:
		if player in focus_area.get_overlapping_bodies() and state != NPCState.ON_SPEECH:
			state = NPCState.READY
		
		if dialogue_box.is_finished() and dialogue_box.empty_dialogues():
			state = NPCState.FINISHED

func update_animation() -> void:
	pass

func _on_npc_dialogue_finished() -> void:
	if state == NPCState.FINISHED:
		await get_tree().create_timer(0.3).timeout
		if player:
			player.change_state_and_direction_forced(
				player.PlayerState.IDLE,
				old_player_direction
			)
		cardinal_direction = Vector2.DOWN

func _on_any_body_exited(body: Node2D) -> void:
	if body is Player:
		arrow.hide()
		state = NPCState.NOT_READY
		player = null

func _on_down_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2.UP, body.direction, $Down)
		cardinal_direction = Vector2.DOWN
		
func _on_right_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2.LEFT, body.direction, $Right)
		cardinal_direction = Vector2.RIGHT
		factor_flip = 1

func _on_left_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2.RIGHT, body.direction, $Left)
		cardinal_direction = Vector2.LEFT
		factor_flip = -1
	
func _on_up_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_on_area(body, Vector2.DOWN, body.direction, $Up)
		cardinal_direction = Vector2.UP
		
func enter_on_area(body: Node2D, new: Vector2, old: Vector2, focus: Area2D) -> void:
	arrow.show()
	state = NPCState.READY
	player = body
	new_player_direction = new
	old_player_direction = old
	focus_area = focus

func _on_computer_pc_activated() -> void:
	has_pong = true
