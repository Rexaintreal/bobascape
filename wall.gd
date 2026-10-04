@tool
extends StaticBody2D

@export var size := Vector2(64, 64):
	set(value):
		size = value
		_update()

func _ready():
	_update()

func _update():
	if not is_inside_tree():
		return
	var collision = get_node_or_null("CollisionShape2D")
	var rect = get_node_or_null("ColorRect")
	if collision == null or rect == null:
		return
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	rect.size = size
	rect.position = -size / 2
