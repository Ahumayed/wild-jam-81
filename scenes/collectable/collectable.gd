extends Node2D

@export var color: Color = Color.DARK_GOLDENROD

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var shapes: Array[Shape2D3D] = []
var drawn_shape: Array = []

func _ready():
	# Add as many shapes as you want here
	shapes.append(Shape2D3D.new(5, 20, 100, Vector3(1, 1, 0)))
	shapes.append(Shape2D3D.new(5, 20, 100, Vector3(-2, 0, 1)))
	


func _process(delta: float) -> void:
	for shape in shapes:
		shape.update(delta)

	var polygons = []
	for shape in shapes:
		polygons.append(shape.get_rotated_points())
	
	var merged = []
	
#	If only one polygon, draw it and return
	if polygons.size() == 1:
		drawn_shape = polygons[0]
		queue_redraw()
		return
	
	while not polygons.is_empty():
		if merged.is_empty():
			merged = Geometry2D.merge_polygons(polygons[0], polygons[1])
			polygons.remove_at(0)
			polygons.remove_at(0)
			
		else:
			merged = Geometry2D.merge_polygons(merged, polygons[0])
			polygons.remove_at(0)

#	Close the loop
	merged[0].append(merged[0][0])
	
	drawn_shape = merged[0]
	queue_redraw()

func _draw():
	if drawn_shape.is_empty():
		return

	draw_polyline_colors(drawn_shape, [Color.DARK_GOLDENROD])


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
