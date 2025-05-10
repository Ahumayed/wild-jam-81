extends AspectRatioContainer

@export var main_scene: String = "res://scenes/test.tscn"
@export var settings_menu_scene: String = "res://scenes/settings_menu.tscn"

func _ready() -> void:
	Global.save_game()

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	Global.change_scene(main_scene)


func _on_settings_button_pressed() -> void:
	Global.change_scene(settings_menu_scene)
