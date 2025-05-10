class_name CaveGenerator
extends Node2D

@export var cave_size := Vector2i(100, 100)
@export var iteration_count := 5
@export var wall_probability: int = 40

const DIRECTIONS = [
	Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i(1, 1),
	Vector2i(-1, 1),
	Vector2i(1, -1),
	Vector2i(-1, -1)
]

func _ready() -> void:
	randomize()

func generate_cave(gen_seed: int = -1) -> Cave:
	var rng := RandomNumberGenerator.new()
	rng.seed = gen_seed if gen_seed != -1 else randi_range(0, 2_147_483_646)

	var cave := Cave.new(cave_size)

	_random_fill(cave, rng)
	_apply_cellular_automata(cave)

	return cave

func _random_fill(cave: Cave, rng: RandomNumberGenerator) -> void:
	for y: int in range(cave.size.y):
		for x: int in range(cave.size.x):
			var n := rng.randi_range(0, 99)
			
			if n < wall_probability:
				cave.walls[Vector2i(x, y)] = true
			else:
				cave.walls[Vector2i(x, y)] = false

func _apply_cellular_automata(cave: Cave) -> void:
	for i in range(iteration_count):
		for y in range(cave.size.y):
			for x in range(cave.size.x):
				var pos := Vector2i(x, y)
				
				if pos.x == 0 or pos.y == 0 or pos.x == cave.size.x - 1 or pos.y == cave.size.y - 1:
					cave.walls[pos] = true
					continue

				var wall_count: int = _get_wall_count(cave.walls, pos)
				var nearby_wall_count := _get_nearby_wall_count(cave, pos)

				if wall_count >= 5 or nearby_wall_count <= 2:
					cave.walls[pos] = true
				else:
					cave.walls[pos] = false
				
				wall_count = _get_wall_count(cave.walls, pos)
				
				if wall_count >= 5:
					cave.walls[pos] = true
				else:
					cave.walls[pos] = false

func _get_wall_count(walls: Dictionary[Vector2i, bool], pos: Vector2i) -> int:
	var count: int = 0

	for y in range(pos.y - 1, pos.y + 2):
		for x in range(pos.x - 1, pos.x + 2): 
			var neighbor := Vector2i(x, y)

			if walls[neighbor]:
				count += 1

	return count

func _get_nearby_wall_count(cave: Cave, pos: Vector2i) -> int:
	var count: int = 0

	for y in range(pos.y - 2, pos.y + 3):
		for x in range(pos.x - 2, pos.x + 3):
			var neighbor := Vector2i(x, y)

			if x < 0 or y < 0 or y >= cave.size.y or x >= cave.size.x:
				continue

			if cave.walls[neighbor]:
				count += 1

	return count

class Cave:
	var walls: Dictionary[Vector2i, bool]
	var size: Vector2i

	func _init(_size: Vector2i) -> void:
		size = _size
		walls = {}
