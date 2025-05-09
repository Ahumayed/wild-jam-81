extends AspectRatioContainer

func _ready() -> void:
	Global.save_game()

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	Global.change_scene("res://scenes/main.tscn")


func _on_settings_button_pressed() -> void:
	Global.change_scene("res://scenes/settings_menu.tscn")
