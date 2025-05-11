class_name Room
extends RefCounted

var cells: Array[Vector2i]
var mean_y_level: float

func _init() -> void:
	cells = []
	mean_y_level = 0
