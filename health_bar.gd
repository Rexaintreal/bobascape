extends ProgressBar

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	max_value = player.max_health
	value = player.health
	player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health, max_health):
	max_value = max_health
	value = new_health
