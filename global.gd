extends Node

var score: int = 0
const SAVE_PATH := "user://save_game.json"

func _ready():
	load_game()

func change_scene(scene_path: String):
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

func restart_scene():
	get_tree().paused = false
	get_tree().reload_current_scene()

func pause_game():
	get_tree().paused = true

func unpause_game():
	get_tree().paused = false

func toggle_pause():
	get_tree().paused = !get_tree().paused

func save_game():
	var data = {
		"score": score
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if result:
		score = result.get("score", 0)
	else:
		print("Failed to parse save file.")
