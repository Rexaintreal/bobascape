extends CharacterBody2D

const SPEED = 200.0

@export var front_texture: Texture2D
@export var back_texture: Texture2D

@onready var sprite = $Sprite2D

func _ready():
	motion_mode = MOTION_MODE_FLOATING

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()

	if direction.y < 0:
		sprite.texture = back_texture
	elif direction != Vector2.ZERO:
		sprite.texture = front_texture

	if direction.x != 0:
		sprite.flip_h = direction.x > 0
