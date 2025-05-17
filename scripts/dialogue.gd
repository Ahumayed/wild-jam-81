extends Panel

@export var game_scene = "res://scenes/test.tscn"
@export var dialogue := """
[b]SYSTEM LOG – ENTRY #001[/b]

Impact detected. Hull integrity compromised.

You’ve crash-landed on an uncharted planet. The ship's main thruster array is destroyed.

Surface scans show minimal resources, but an underground cave system nearby may contain salvageable materials.

Launching exploration drone...

Press Enter to continue...
"""

@onready var timer: Timer = $Timer
@onready var rich_text_label: RichTextLabel = $Label

var current_text = ""
var text_length
var text_progress: int = 0

func _ready() -> void:
	rich_text_label.text = ""
	text_length = len(dialogue)
	timer.start()

func _on_timer_timeout() -> void:
	if text_progress < text_length:
		text_progress += 1
		_update_text()
	else:
		timer.stop()

func _update_text():
	rich_text_label.text = dialogue.substr(0, text_progress)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		Global.change_scene(game_scene)
