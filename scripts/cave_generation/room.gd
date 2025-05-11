class_name Room
extends RefCounted

var cells: Array[Vector2i]
var mean_pos: Vector2i

func _init() -> void:
	cells = []
	mean_pos = Vector2i.ZERO

