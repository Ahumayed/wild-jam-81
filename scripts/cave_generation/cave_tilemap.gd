class_name CaveTileMap
extends TileMapLayer

@export var cave_tile_atlas_coords: Vector2i

@onready var cave_generator: CaveGenerator = $CaveGenerator

func _ready() -> void:
	var cave := cave_generator.generate_cave()

	for y in range(cave.size.y):
		for x in range(cave.size.x):
			var pos := Vector2i(x, y)

			var is_wall: bool = cave.walls[pos]
			
			if is_wall:
				set_cell(pos, 1, cave_tile_atlas_coords)
