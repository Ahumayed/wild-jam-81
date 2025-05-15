class_name CaveTileMap
extends TileMapLayer

@export var cave_background_tile := Vector2i(0, 3)
@export var source_id: int = 0
@export var gem_count: int = 4

@onready var cave_generator: CaveGenerator = $CaveGenerator

var cave = null

func _ready() -> void:
	_generate_cave()

# # For debugging purposes
# func _process(_delta: float) -> void:
# 	if Input.is_action_just_pressed("fly_up"):
# 		_generate_cave()

func _generate_cave() -> void:
	cave = cave_generator.generate_cave()

	var walls: Array[Vector2i] = []

	for y in range(cave.size.y):
		for x in range(cave.size.x):
			var pos := Vector2i(x, y)

			var is_wall: bool = cave.walls[pos]
			
			if is_wall:
				walls.append(pos)
	
	set_cells_terrain_connect(walls, 0, 0)
	
	for cell in cave.room.cells:
		set_cell(cell, source_id, cave_background_tile)
