class_name PriorityQueue
extends RefCounted

var _decider_func: Callable
var _heap: Array[PriorityNode]

func _init(_decider: Callable) -> void:
	_decider_func = _decider

func append(value, priority: float) -> void:
	pass

func _left(i: int) -> void:
	pass

func _right(i: int) -> void:
	pass

class PriorityNode:
	var priority: float
	var value

	func _init(_priority: float, _value) -> void:
		priority = _priority
		value = _value

