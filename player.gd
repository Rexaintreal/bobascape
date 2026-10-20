extends CharacterBody2D

signal health_changed(new_health, max_health)
signal died
signal boba_collected

const SPEED = 200.0
const DASH_SPEED = 650.0
const DASH_TIME = 0.15
const DASH_COOLDOWN = 0.8
const ATTACK_DAMAGE = 15
const ATTACK_COOLDOWN = 0.35
const FRONT_TEXTURE = preload("res://assets/orpheus_front.png")
const BACK_TEXTURE = preload("res://assets/orpheus_back.png")

@export var max_health := 100

var health := 100
var facing := Vector2.DOWN
var attack_timer := 0.0
var dash_timer := 0.0
var dash_cd := 0.0
var dash_dir := Vector2.ZERO
var invuln := 0.0
var slash_t := 0.0
var rush := 0.0
var dead := false

@onready var sprite = $Sprite2D
@onready var attack_area = $AttackArea

func _ready():
	motion_mode = MOTION_MODE_FLOATING
	add_to_group("player")
	health = max_health

func _physics_process(delta):
	if dead:
		return
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed = SPEED * (1.4 if rush > 0.0 else 1.0)

	dash_timer -= delta
	dash_cd -= delta
	invuln -= delta
	rush -= delta
	slash_t -= delta
	attack_timer -= delta

	if Input.is_action_just_pressed("dash") and dash_cd <= 0.0:
		dash_dir = direction if direction != Vector2.ZERO else facing
		dash_timer = DASH_TIME
		dash_cd = DASH_COOLDOWN
		invuln = DASH_TIME + 0.1
		sprite.modulate = Color(1, 1, 1, 0.5)
		create_tween().tween_property(sprite, "modulate", Color.WHITE, DASH_TIME + 0.1)

	if dash_timer > 0.0:
		velocity = dash_dir * DASH_SPEED
	else:
		velocity = direction * speed
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
	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		attack()
	queue_redraw()

func _draw():
	if slash_t > 0.0:
		draw_arc(Vector2.ZERO, 95.0, facing.angle() - 0.9, facing.angle() + 0.9, 16, Color(1, 0.85, 0.3, slash_t / 0.15), 10.0)

func attack():
	attack_timer = ATTACK_COOLDOWN * (0.6 if rush > 0.0 else 1.0)
	slash_t = 0.15
	sprite.modulate = Color(1, 1, 0.4)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.2)
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(ATTACK_DAMAGE, global_position)

func take_damage(amount):
	if invuln > 0.0 or dead:
		return
	invuln = 0.5
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	sprite.modulate = Color(1, 0.3, 0.3)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.3)
	if health <= 0:
		dead = true
		died.emit()

func heal(amount):
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)

func collect_boba(amount):
	heal(amount)
	rush = 5.0
	boba_collected.emit()
