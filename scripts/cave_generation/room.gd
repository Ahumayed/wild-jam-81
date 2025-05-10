class_name Room
extends RefCounted

var cells: Array[Vector2i]
var center: Vector2i

func _init(_center: Vector2i) -> void:
	center = _center
