class_name PriorityList
extends RefCounted

var _decider_func: Callable
var _heap: Array[PriorityNode]

func _init(_decider: Callable) -> void:
	_decider_func = _decider
	_heap = []

func append(value, priority: float) -> void:
	_heap.append(PriorityNode.new(priority, value))

	if _heap.size() == 1: # if the element jsut added was the first element, no need to check
		return

# cant use 'get' because its a native godot function :(
func find(i: int):
	return _heap[i].value

func size() -> int:
	return _heap.size()

func _cascade_up(i: int) -> void:
	if i == 0:
		return

	var node = _heap[i]
	var parent_idx := _parent(i)
	var parent := _heap[parent_idx]
	
	if _decider_func.call(parent.priority, node.priority):
		_swap(i, parent_idx)
		_cascade_up(parent_idx)

func _swap(i: int, j: int) -> void:
	var n1 = _heap[i]
	var n2 = _heap[j]

	_heap[i].priority = n2.priority
	_heap[i].value = n2.value
	_heap[j].priority = n1.priority
	_heap[i].value = n1.value

func _parent(i: int) -> int:
	@warning_ignore("INTEGER_DIVISION")
	return floor((i - 1) / 2)

func _left(i: int) -> int:
	return (2 * i) + 1

func _right(i: int) -> int:
	return (2 * i) + 2

class PriorityNode:
	var priority: float
	var value

	func _init(_priority: float, _value) -> void:
		priority = _priority
		value = _value
