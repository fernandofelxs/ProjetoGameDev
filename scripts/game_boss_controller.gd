class_name GameBossController extends Node2D

@export var player: Player = null
@export var transition: Transition = null
@export var boss: Boss = null

func _ready() -> void:
	player.connect("player_dead", Callable(self, "_on_player_dead"))
	boss.connect("boss_dead", Callable(self, "_on_boss_dead"))

func _on_player_dead() -> void:
	await get_tree().create_timer(3).timeout
	transition.change_scene("game_over")

func _on_boss_dead() -> void:
	await get_tree().create_timer(3).timeout
	transition.change_scene("credits")	
