extends Node2D

@export var enemy_scene: PackedScene = preload("res://enemy.tscn")
@export var boba_scene: PackedScene = preload("res://boba.tscn")
@export var arena := Rect2(60, 60, 1030, 530)

var score := 0
var wave := 0
var between_waves := false
var game_over := false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var wave_label = $CanvasLayer/WaveLabel
@onready var message = $CanvasLayer/Message

func _ready():
	randomize()
	message.text = ""
	player.died.connect(_on_player_died)
	player.boba_collected.connect(func(): _add_score(5))
	_update_ui()

func _process(_delta):
	if game_over:
		if Input.is_key_pressed(KEY_R) or Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	if not between_waves and get_tree().get_nodes_in_group("enemy").is_empty():
		_next_wave()

func _next_wave():
	between_waves = true
	wave += 1
	_update_ui()
	message.text = "Wave %d" % wave
	_spawn_boba(_free_spot())
	await get_tree().create_timer(1.5).timeout
	message.text = ""
	if game_over:
		return
	for i in 2 + wave * 2:
		_spawn_enemy()
	between_waves = false

func _spawn_enemy():
	var e = enemy_scene.instantiate()
	e.speed += wave * 6
	e.health += wave * 5
	e.detect_range = 2000.0
	e.died.connect(_on_enemy_died)
	add_child(e)
	e.global_position = _free_spot()

func _spawn_boba(pos: Vector2):
	var b = boba_scene.instantiate()
	add_child(b)
	b.global_position = pos

func _on_enemy_died(pos: Vector2):
	_add_score(10)
	if randf() < 0.3:
		_spawn_boba.call_deferred(pos)

func _add_score(n):
	score += n
	_update_ui()

func _update_ui():
	score_label.text = "Score: %d" % score
	wave_label.text = "Wave %d" % wave

func _on_player_died():
	game_over = true
	message.text = "GAME OVER\nScore: %d\nPress R to retry" % score

func _free_spot() -> Vector2:
	var space = get_world_2d().direct_space_state
	for i in 40:
		var p = Vector2(randf_range(arena.position.x, arena.end.x),
				randf_range(arena.position.y, arena.end.y))
		var q = PhysicsPointQueryParameters2D.new()
		q.position = p
		if space.intersect_point(q, 1).is_empty() and p.distance_to(player.global_position) > 300.0:
			return p
	return arena.get_center()
