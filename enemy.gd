extends CharacterBody2D

@export var speed := 90.0
@export var damage := 10
@export var health := 30
@export var detect_range := 350.0

var cooldown := 0.0
var knock := Vector2.ZERO
var player: Node2D

@onready var health_bar = get_node_or_null("HealthBar")
@onready var sprite = $Sprite2D

func _ready():
	motion_mode = MOTION_MODE_FLOATING
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	if health_bar != null:
		health_bar.max_value = health
		health_bar.value = health

func _physics_process(delta):
	if player == null:
		return

	var to_player = player.global_position - global_position
	var chase = Vector2.ZERO
	if to_player.length() < detect_range:
		chase = to_player.normalized() * speed
		sprite.flip_h = to_player.x > 0
	velocity = chase + knock
	knock = knock.move_toward(Vector2.ZERO, 1400.0 * delta)
	move_and_slide()

	cooldown -= delta
	for i in get_slide_collision_count():
		var other = get_slide_collision(i).get_collider()
		if other.is_in_group("player") and cooldown <= 0.0:
			other.take_damage(damage)
			cooldown = 1.0

func take_damage(amount, from_pos := Vector2.ZERO):
	health -= amount
	if health_bar != null:
		health_bar.value = health
	if from_pos != Vector2.ZERO:
		knock = (global_position - from_pos).normalized() * 450.0
	modulate = Color(1, 1, 1, 0.3)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	if health <= 0:
		queue_free()
