class_name CaveGenerator
extends TileMapLayer

@export var cave_size := Vector2i(100, 100)
@export var cave_room_count: int = 10
@export var bridge_rooms := true
@export var room_size_min: int = 50
@export var room_size_max: int = 200

var rooms: Array[Room]

func _ready() -> void:
	pass

func generate_room(pos: Vector2) -> void:
	pass
