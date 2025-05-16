class_name CollectableGenerator
extends Node2D

@export_category("Sides")
@export var sides_range := Vector2i(2, 4)
@export var sides_scaling_factor: float = 1

@export_category("Radii")
@export var min_radius_range := Vector2(20, 40)
@export var max_radius_range := Vector2(50, 150)

@export_category("Shape Count")
@export var shape_range := Vector2i(1, 2)
@export var shape_scaling_factor: float = 1

@export_category("Rotation Speed")
@export var speed_range := Vector2(0.1, 2.0)

@onready var collectable: Collectable = $Collectable

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	generate(rng, 4)

func generate(rng: RandomNumberGenerator, complexity: int = 1) -> void:
	var shape_count: int = floor(rng.randi_range(shape_range.x, shape_range.y) * (complexity * shape_scaling_factor))

	for i in range(shape_count):
		_add_shape(rng, complexity)

func _add_shape(rng: RandomNumberGenerator, complexity: int) -> void:
	var min_radius := rng.randf_range(min_radius_range.x, min_radius_range.y)
	var max_radius := rng.randf_range(max_radius_range.x, max_radius_range.y)
	var sides_count: int = floor(rng.randi_range(sides_range.x, sides_range.y) * (complexity * sides_scaling_factor))
	var rotation_speed_length := rng.randf_range(speed_range.x, speed_range.y)
	var rotation_speed := Vector3(1, 1, 0) * rotation_speed_length

	collectable.shapes.append(Shape2D3D.new(sides_count, max_radius, min_radius, rotation_speed))

