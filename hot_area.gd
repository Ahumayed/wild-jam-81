extends Area2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var hot_bodies: Array = []

func _process(delta: float) -> void:
	if len(hot_bodies) > 0:
		if not audio_stream_player.playing:
			audio_stream_player.play()
	else:
		audio_stream_player.stop()

func _on_body_entered(popcorn: Node2D) -> void:
	if popcorn is Popcorn:
		hot_bodies.append(popcorn)
		popcorn.on_in_heat()


func _on_body_exited(popcorn: Node2D) -> void:
	if popcorn is Popcorn:
		hot_bodies.erase(popcorn)
		popcorn.on_off_heat()
