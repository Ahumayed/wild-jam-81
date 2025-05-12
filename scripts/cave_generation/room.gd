class_name Room
extends RefCounted

var cells: Array[Vector2i]
var walls: PriorityList

func _init() -> void:
	cells = []
	walls = PriorityList.new(func(a, b):
		return a < b
	)
