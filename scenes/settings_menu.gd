extends AspectRatioContainer

var master_volume = 0
var sfx_volume = 0
var music_volume = 0

@onready var master_slider: HSlider = $VBoxContainer/Master/MasterSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFX/SFXSlider
@onready var music_slider: HSlider = $VBoxContainer/Music/MusicSlider


func _ready() -> void:
	master_volume = AudioServer.get_bus_volume_linear(0)
	master_slider.value = master_volume
	
	sfx_volume = AudioServer.get_bus_volume_linear(2)
	sfx_slider.value = sfx_volume
	
	music_volume = AudioServer.get_bus_volume_linear(1)
	music_slider.value = music_volume
	
func _on_exit_button_pressed() -> void:
	Global.change_scene("res://scenes/main_menu.tscn")


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value)
