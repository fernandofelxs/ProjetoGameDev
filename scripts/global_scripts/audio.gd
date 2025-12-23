extends Node

var ui_click := preload("res://audio/ui/ui_click.wav.ogg")
var damage := preload("res://audio/combat/damage.wav.ogg")
var attack := preload("res://audio/combat/attack.wav.ogg")
var enemy_hit := preload("res://audio/combat/enemy_hit.ogg")
var slime_death := preload("res://audio/combat/slime_death.ogg")
var basic_enemy_death := preload("res://audio/combat/basic_enemy_death.ogg")
var strong_enemy_death := preload("res://audio/combat/strong_enemy_death.ogg")
var door_open := preload("res://audio/interactions/door_open.wav.ogg")
var door_close := preload("res://audio/interactions/door_close.wav.ogg")
var use_calculus_book := preload("res://audio/interactions/use_calculus_book.ogg")
var use_medkit := preload("res://audio/interactions/use_medkit.ogg")
var footsteps := preload("res://audio/player/footsteps.ogg.mp3")
var menu_music := preload("res://audio/music/menu_music.ogg")
var game_music := preload("res://audio/music/game_music.ogg")
var pickup := preload("res://audio/player/pickup.ogg.mp3")


var music_player: AudioStreamPlayer
var footsteps_player: AudioStreamPlayer
var is_walking := false

func play_ui_click():
	var player = AudioStreamPlayer.new()
	player.stream = ui_click
	add_child(player)
	player.play()

func play_damage():
	var player = AudioStreamPlayer.new()
	player.stream = damage
	add_child(player)
	player.play()

func play_attack():
	var player = AudioStreamPlayer.new()
	player.stream = attack
	add_child(player)
	player.play()
	
func play_enemy_hit():
	var player = AudioStreamPlayer.new()
	player.stream = enemy_hit
	add_child(player)
	player.play()
	
func play_slime_death():
	var player = AudioStreamPlayer.new()
	player.stream = slime_death
	add_child(player)
	player.play()

func play_basic_enemy_death():
	var player = AudioStreamPlayer.new()
	player.stream = basic_enemy_death
	add_child(player)
	player.play()
	
func play_strong_enemy_death():
	var player = AudioStreamPlayer.new()
	player.stream = strong_enemy_death
	add_child(player)
	player.play()

func play_door_open():
	var player = AudioStreamPlayer.new()
	player.stream = door_open
	add_child(player)
	player.play()

func play_door_close():
	var player = AudioStreamPlayer.new()
	player.stream = door_close
	add_child(player)
	player.play()

func play_use_calculus_book():
	var player = AudioStreamPlayer.new()
	player.stream = use_calculus_book
	add_child(player)
	player.play()

func play_use_medkit():
	var player = AudioStreamPlayer.new()
	player.stream = use_medkit
	add_child(player)
	player.play()

func _ready():
	menu_music.loop = true
	game_music.loop = true

	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	footsteps.loop = true
	footsteps_player = AudioStreamPlayer.new()
	footsteps_player.stream = footsteps
	add_child(footsteps_player)

func start_walk():
	if is_walking:
		return
	
	is_walking = true
	footsteps_player.play()

func stop_walk():
	if not is_walking:
		return
	
	is_walking = false
	footsteps_player.stop()

func play_music_menu():
	if music_player.playing:
		return

	music_player.stream = menu_music
	music_player.play()

func play_music_game():
	if music_player.playing:
		music_player.stop()

	music_player.stream = game_music
	music_player.play()

func play_pickup():
	var player = AudioStreamPlayer.new()
	player.stream = pickup
	add_child(player)
	player.play()
