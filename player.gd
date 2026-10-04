extends CharacterBody2D

signal health_changed(new_health, max_health)

const SPEED = 200.0
const ATTACK_DAMAGE = 10
const ATTACK_COOLDOWN = 0.4

@export var max_health := 100
const FRONT_TEXTURE = preload("res://assets/orpheus_front.png")
const BACK_TEXTURE = preload("res://assets/orpheus_back.png")

var health := 100
var facing := Vector2.DOWN
var attack_timer := 0.0

@onready var sprite = $Sprite2D
@onready var attack_area = $AttackArea

func _ready():
	motion_mode = MOTION_MODE_FLOATING
	add_to_group("player")
	health = max_health

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()

	if direction.y < 0:
		sprite.texture = BACK_TEXTURE
	elif direction != Vector2.ZERO:
		sprite.texture = FRONT_TEXTURE

	if direction.x != 0:
		sprite.flip_h = direction.x > 0

	if direction != Vector2.ZERO:
		facing = direction.normalized()
	attack_area.position = facing * 60
	attack_timer -= delta
	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		attack()

func attack():
	attack_timer = ATTACK_COOLDOWN
	sprite.modulate = Color(1, 1, 0.4)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.2)
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(ATTACK_DAMAGE)

func take_damage(amount):
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		get_tree().call_deferred("reload_current_scene")

func heal(amount):
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
