class_name Collectable
extends Node2D

@export var color: Color = Color.DARK_GOLDENROD
@export var thickness: int = 3
@export var sides: int = 3
@export var outer_radius: float = 100.0
@export var inner_radius: float = 50.0
@export var rotation_speed: Vector3 = Vector3(1, 1, 0)

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D

var shapes: Array[Shape2D3D] = []
var drawn_shape: Array = []

func _ready():
	var shape = Shape2D3D.new(sides, outer_radius, inner_radius, rotation_speed)
	shapes.append(shape)
	
	collision_shape_2d.shape.radius = outer_radius
	point_light_2d.color = color

func _process(delta: float) -> void:
	for shape in shapes:
		shape.update(delta)

	var polygons = []
	for shape in shapes:
		polygons.append(shape.get_rotated_points())

	if polygons.size() == 1:
		drawn_shape = polygons[0]
	else:
		var merged = Geometry2D.merge_polygons(polygons[0], polygons[1])
		for i in range(2, polygons.size()):
			merged = Geometry2D.merge_polygons(merged, polygons[i])
			

		drawn_shape = merged[0]


	queue_redraw()

func _draw():
	if drawn_shape.is_empty():
		return
	
	drawn_shape.append(drawn_shape[0])
	draw_polyline_colors(drawn_shape, [color], thickness)

func merge(other: Collectable) -> void:
	for shape in other.shapes:
		shapes.append(shape)
	
	collision_shape_2d.shape.radius = max(outer_radius, other.outer_radius)
	other.queue_free()



###############################
class Shape2D3D:
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
