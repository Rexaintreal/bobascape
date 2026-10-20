extends Node

var sounds := {}

func _ready():
	for n in ["swing", "hit", "pickup", "hurt", "dash", "wave", "gameover"]:
		for ext in ["wav", "mp3", "ogg"]:
			var path = "res://audio/%s.%s" % [n, ext]
			if ResourceLoader.exists(path):
				sounds[n] = load(path)
				break

func play(n: String, pitch_var := 0.1):
	if not sounds.has(n):
		return
	var p = AudioStreamPlayer.new()
	p.stream = sounds[n]
	p.pitch_scale = randf_range(1.0 - pitch_var, 1.0 + pitch_var)
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
