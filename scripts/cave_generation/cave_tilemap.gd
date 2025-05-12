class_name CaveTileMap
extends TileMapLayer

@export var cave_tile_atlas_coords: Vector2i
@export var source_id: int = 0
@export var gem_count: int = 4

@onready var cave_generator: CaveGenerator = $CaveGenerator

var cave = null

func _ready() -> void:
	cave = cave_generator.generate_cave()

	for y in range(cave.size.y):
		for x in range(cave.size.x):
			var pos := Vector2i(x, y)

			var is_wall: bool = cave.walls[pos]
			
			if is_wall:
				set_cell(pos, source_id, cave_tile_atlas_coords)
	
	for i in range(gem_count):
		var j: int = (cave.room.walls.size() - 1) / (i + 1)
		var wall: Vector2i = cave.room.walls.find(j)
		set_cell(wall, source_id, Vector2i(3, 2) + Vector2i(i, 0))
