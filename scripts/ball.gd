extends CharacterBody2D

var win_size: Vector2

const START_SPEED := 1200
const ACCEL := 50
const MAX_Y_VECTOR := 0.6
const SEPARATION := 2.0  

var speed: int
var dir: Vector2

const LAYER_1 := 1 << 0
const LAYER_6 := 1 << 5

const NORMAL_MASK := LAYER_1
const RED_MASK := LAYER_1 | LAYER_6


@onready var rect: ColorRect = $ColorRect
var default_color: Color

func _ready():
	win_size = get_viewport_rect().size
	default_color = rect.color

func new_ball():
	position.x = win_size.x / 2
	position.y = randi_range(200, win_size.y - 200)
	speed = START_SPEED
	dir = random_direction()
	rect.color = default_color

func _physics_process(delta: float):
	var motion := dir * speed * delta
	var collision := move_and_collide(motion)

	if collision:
		var normal := collision.get_normal()
		var collider := collision.get_collider()

		position -= collision.get_remainder()

		if collider is Boss:
			var knockback_direction := dir.normalized()
			collider.apply_damage(20, knockback_direction)

			# bounce after hitting boss
			dir = dir.bounce(normal)

		if collider == $"../Player":
			set_red_state()
			dir = dir.bounce(normal)

		elif collider == $"../LeftBar" or collider == $"../RightBar":
			speed += ACCEL
			set_normal_state()
			dir = new_direction(collider)

		else:
			set_normal_state()
			dir = dir.bounce(normal)

		dir = dir.normalized()



func random_direction():
	var new_dir := Vector2()
	new_dir.x = [1, -1].pick_random()
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()

func new_direction(collider):
	var ball_y = position.y
	var pad_y = collider.position.y
	var dist = ball_y - pad_y
	var new_dir := Vector2()
	
	if dir.x > 0:
		new_dir.x = -1
	else:
		new_dir.x = 1
	new_dir.y = (dist / (collider.paddle_height / 2)) * MAX_Y_VECTOR
	new_dir.y += randf_range(-0.6, 0.6)
	
	return new_dir.normalized()

func set_red_state():
	rect.color = Color.RED
	collision_layer = RED_MASK
	collision_mask = RED_MASK

func set_normal_state():
	rect.color = default_color
	collision_layer = LAYER_1
	collision_mask = LAYER_1
