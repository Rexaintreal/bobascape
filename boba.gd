extends Area2D

@export var heal_amount := 25

func _ready():
	body_entered.connect(_on_body_entered)
	var t = create_tween().set_loops()
	t.tween_property($Sprite2D, "position:y", -8.0, 0.6).set_trans(Tween.TRANS_SINE)
	t.tween_property($Sprite2D, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.collect_boba(heal_amount)
		queue_free()
