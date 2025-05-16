class_name CaveGenerator
extends Node2D

@export var cave_size := Vector2i(100, 100)
@export var iteration_count := 5
@export var wall_probability: int = 40
@export var make_bridges: bool = true
@export var gem_count: int = 10
@export var thread_count: int = 1

const DIRECTIONS = [
	Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.DOWN,
]

func _ready() -> void:
	randomize()

func generate_cave(gen_seed: int = -1) -> Cave:
	var s := gen_seed if gen_seed != -1 else randi_range(0, 2_147_483_646)
	return _generate_cave(s)

func _generate_cave(gen_seed: int) -> Cave:
	var rng := RandomNumberGenerator.new()
	rng.seed = gen_seed

	var cave := Cave.new(cave_size, gem_count)

	_random_fill(cave, rng)

	if thread_count > cave.size.y:
		thread_count = cave.size.y

	var threads: Array[Thread] = []
	var row_count: int = ceil(float(cave.size.y) / thread_count)

	for i in range(thread_count):
		var thread := Thread.new()
		
		var from := Vector2i(1, i * row_count)
		var to := Vector2i(cave.size.x, (i * row_count) + row_count)

		if to.y >= cave.size.y:
			to.y = cave.size.y - 2

		thread.start(_apply_cellular_automata.bind(cave, from, to))
		threads.append(thread)

	for thread in threads:
		thread.wait_to_finish()

	_find_rooms(cave, rng)

	return cave

func _random_fill(cave: Cave, rng: RandomNumberGenerator) -> void:
	for y: int in range(cave.size.y):
		for x: int in range(cave.size.x):
			var n := rng.randi_range(0, 99)
			var pos := Vector2i(x, y)

			if pos.x == 0 or pos.y == 0 or pos.x == cave.size.x - 1 or pos.y == cave.size.y - 1:
				cave.walls[pos] = true
				continue
			
			if n < wall_probability:
				cave.walls[pos] = true
			else:
				cave.walls[pos] = false

func _apply_cellular_automata(cave: Cave, from: Vector2i, to: Vector2i) -> void:
	var wall_adjacencies := {}
	var nearby_walls := {}
	for i in range(iteration_count):
		for y in range(from.y, to.y):
			for x in range(from.x, to.x - 1):
				var pos := Vector2i(x, y)

				if pos.x == 0 or pos.y == 0 or pos.x == cave.size.x - 1 or pos.y == cave.size.y - 1:
					cave.walls[pos] = true
					continue

				if not (pos in wall_adjacencies):
					wall_adjacencies[pos] = _get_wall_count(cave.walls, pos)
					nearby_walls[pos] = _get_nearby_wall_count(cave, pos)

				if wall_adjacencies[pos] >= 5 or nearby_walls[pos] <= 2:
					if not cave.walls[pos]:
						wall_adjacencies[pos] += 1

					cave.walls[pos] = true
				else:
					cave.walls[pos] = false
				
				if wall_adjacencies[pos] >= 5:
					if not cave.walls[pos]:
						wall_adjacencies[pos] += 1

					cave.walls[pos] = true
				else:
					cave.walls[pos] = false

func _find_rooms(cave: Cave, rng: RandomNumberGenerator) -> void:
	var visited: Dictionary[Vector2i, bool] = {}

	for cell: Vector2i in cave.walls:
		if cave.walls[cell] or cell in visited:
			continue

		var room := _flood_fill(cave, visited, cell, rng)
		
		if room.cells.size() < cave.room.cells.size():
			for pos in room.cells:
				cave.walls[pos] = true
		else:
			for pos in cave.room.cells:
				cave.walls[pos] = true
			cave.room = room

func _flood_fill(cave: Cave, visited: Dictionary[Vector2i, bool], from: Vector2i, rng: RandomNumberGenerator) -> Room:
	var y_ranges: Array[Array] = []
	for i in range(gem_count):
		y_ranges.append([])

	var room := Room.new(gem_count)
	room.cells = [from]

	var current_cells := [from]
	while not current_cells.is_empty():
		var cell: Vector2i = current_cells.pop_back()
		
		if cell in visited:
			continue
		

		visited[cell] = true
		room.cells.append(cell)

		var cell_y_index: int = floor(float(cell.y) / cave.gem_y_range)
		y_ranges[cell_y_index].append(cell)

		var surrounding := _get_surrounding_cells(cave.walls, cell)
		
		for neighbor in surrounding:
			current_cells.append(neighbor)
	
	for y_range in y_ranges:
		if y_range.size() == 0:
			continue

		var idx := rng.randi_range(0, y_range.size() - 1)
		var gem_location: Vector2i = y_range[idx]

		room.gem_locations.append(gem_location)

	return room

func _get_surrounding_cells(walls: Dictionary[Vector2i, bool], pos: Vector2i) -> Array:
	var cells := []

	for direction: Vector2i in DIRECTIONS:
		var neighbor := pos + direction
		
		if not (neighbor in walls) or walls[neighbor]:
			continue

		cells.append(neighbor)

	return cells

func _get_surrounding_walls(walls: Dictionary[Vector2i, bool], pos: Vector2i) -> Array:
	var cells := []
	
	for direction: Vector2i in DIRECTIONS:
		var neighbor := pos + direction

		if not (neighbor in walls) or not walls[neighbor]:
			continue

		cells.append(neighbor)

	return cells

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
	var room: Room
	var gem_y_range: int

	func _init(_size: Vector2i, gem_count: int) -> void:
		size = _size
		walls = {}
		room = Room.new(gem_count)
		gem_y_range = floor(float(size.y) / gem_count)
