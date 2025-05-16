class_name Collectable
extends Node2D

@export var thickness: float = 3.0

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D

var shapes: Array[Shape2D3D] = []
var drawn_shape: Array = []

func _ready():
	pass

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
	draw_polyline_colors(drawn_shape, [Color.RED], thickness)

func merge(other: Collectable) -> void:
	for shape in other.shapes:
		shapes.append(shape)
	
	# collision_shape_2d.shape.radius = max(outer_radius, other.outer_radius)
	other.queue_free()



###############################
