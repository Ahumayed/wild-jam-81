class_name CaveGenerator
extends Node2D

@export var cave_size := Vector2i(100, 100)
@export var cave_room_count: int = 10
@export var bridge_rooms := true
@export var room_size_min: int = 50
@export var room_size_max: int = 200

func _ready() -> void:
	pass

func generate_cave() -> PriorityList:
	var rooms := PriorityList.new(func(a: float, b: float):
		return a < b
	)
	return rooms

func generate_room(pos: Vector2) -> void:
	pass
