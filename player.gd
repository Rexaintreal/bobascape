extends CharacterBody2D

signal health_changed(new_health, max_health)

const SPEED = 200.0

@export var max_health := 100
const FRONT_TEXTURE = preload("res://assets/orpheus_front.png")
const BACK_TEXTURE = preload("res://assets/orpheus_back.png")

var health := 100

@onready var sprite = $Sprite2D

func _ready():
	motion_mode = MOTION_MODE_FLOATING
	add_to_group("player")
	health = max_health

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()

	if direction.y < 0:
		sprite.texture = BACK_TEXTURE
	elif direction != Vector2.ZERO:
		sprite.texture = FRONT_TEXTURE

	if direction.x != 0:
		sprite.flip_h = direction.x > 0

func take_damage(amount):
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		get_tree().call_deferred("reload_current_scene")

func heal(amount):
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
