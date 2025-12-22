class_name HealthBar extends Node2D
@onready var health_bar: Sprite2D = $Health
@onready var default_width: float = health_bar.region_rect.size.x
@onready var default_height: float = health_bar.region_rect.size.y

func update_health(new_health: int) -> void:
	var actual_health = new_health
	if new_health < 0:
		actual_health = 0
	var new_width = (actual_health / 100.0) * default_width
	health_bar.region_rect = Rect2(0, 0, new_width, default_height)
