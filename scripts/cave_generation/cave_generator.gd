class_name CaveGenerator
extends Node2D

@export var cave_size := Vector2i(100, 100)
@export var cave_room_count: int = 10
@export var bridge_rooms := true
@export var room_size_min: int = 50
@export var room_size_max: int = 200

func _ready() -> void:
	randomize()

func generate_cave(gen_seed: int = -1) -> PriorityList:
	var rng := RandomNumberGenerator.new()
	rng.seed = gen_seed if gen_seed != -1 else randi_range(0, 2_147_483_646)

	var rooms := PriorityList.new(func(a: float, b: float):
		return a < b
	)
	return rooms

func generate_room(pos: Vector2) -> Room:
	var room := Room.new(pos)
	return room
