class_name Room
extends RefCounted

var cells: Array[Vector2i]
var gem_count: int
var gem_locations: Array[Vector2i]

func _init(_gem_count: int) -> void:
	cells = []
	gem_count = 0
	gem_locations = []
