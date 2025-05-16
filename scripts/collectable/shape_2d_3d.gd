class_name Shape2D3D
extends RefCounted

var sides_count: int
var outer_radius: float
var inner_radius: float
var rotation_speed: Vector3
var current_rotation := Vector3.ZERO
var points: PackedVector2Array

func _init(sides_count: int, outer_radius: float, inner_radius: float = -1.0, rotation_speed := Vector3.ZERO):
	self.sides_count = sides_count
	self.outer_radius = outer_radius
	self.inner_radius = inner_radius if inner_radius > 0 else outer_radius * 0.5
	self.rotation_speed = rotation_speed
	self.points = generate_regular_star_polygon(sides_count, outer_radius, self.inner_radius)

func update(delta: float):
	self.current_rotation += rotation_speed * delta

func get_rotated_points() -> Array:
	return rotate_2d_points_3d(self.points, self.current_rotation)

func generate_regular_star_polygon(sides: int, outer_radius: float, inner_radius: float = -1.0, rotation_offset := 0.0) -> PackedVector2Array:
	if inner_radius <= 0.0:
		inner_radius = outer_radius * 0.5

	var points = PackedVector2Array()
	var step = TAU / (sides * 2)

	for i in range(sides * 2):
		var angle = step * i + rotation_offset
		var radius = outer_radius if i % 2 == 0 else inner_radius
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	return points

func rotate_2d_points_3d(points_2d: Array, rotation: Vector3) -> Array:
	var result = []
	for p in points_2d:
		var p3 = Vector3(p.x, 0, p.y)
		p3 = p3.rotated(Vector3(1, 0, 0), rotation.x)
		p3 = p3.rotated(Vector3(0, 1, 0), rotation.y)
		p3 = p3.rotated(Vector3(0, 0, 1), rotation.z)
		result.append(Vector2(p3.x, p3.z))  # Project to 2D (XZ view)
		
	return result
