extends Node2D

const PADDLE_SPEED : int = 600

func _ready() -> void:
	AudioManager.play_music_boss_fight()

func _on_ball_timer_timeout() -> void:
	$Ball.new_ball()

func _on_left_body_entered(body: Node2D) -> void:
	if body == $Ball:
		$BallTimer.start()

func _on_right_body_entered(body: Node2D) -> void:
	if body == $Ball:
		$BallTimer.start()
