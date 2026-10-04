extends CharacterBody2D

@export var speed := 90.0
@export var damage := 10
@export var health := 30
@export var detect_range := 350.0 

var cooldown := 0.0 
var player: Node2D

@onready var health_bar = get_node_or_null("HealthBar")

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
	if to_player.length() < detect_range:
		velocity = to_player.normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	cooldown -= delta
	for i in get_slide_collision_count():
		var other = get_slide_collision(i).get_collider()
		if other.is_in_group("player") and cooldown <= 0.0:
			other.take_damage(damage)
			cooldown = 1.0

func take_damage(amount):
	health -= amount
	if health_bar != null:
		health_bar.value = health
	modulate = Color(1, 1, 1, 0.3)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	if health <= 0:
		queue_free()
