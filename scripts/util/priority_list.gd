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
	
	_cascade_up(_heap.size() - 1)

# cant use 'get' because its a native godot function :(
func find(i: int):
	return _heap[i].value

func size() -> int:
	return _heap.size()

func has(value) -> bool:
	return value in _heap	

func print() -> void:
	for node in _heap:
		print()
		print(node.priority)
		print()

func _cascade_up(i: int) -> void:
	while i > 0:
		var parent_idx = _parent(i)

		if _decider_func.call(_heap[i].priority, _heap[parent_idx].priority):
			_swap(i, parent_idx)
			i = parent_idx
		else:
			break

func _swap(i: int, j: int) -> void:
	var temp = _heap[i]
	_heap[i] = _heap[j]
	_heap[j] = temp

func _parent(i: int) -> int:
	return floor(float(i - 1) / float(2))

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
