class_name ItemManager
extends Area2D

@export var grab_force: float = 50.0

var current_item: Item = null
var items_in_radius: Array[Item] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		if current_item != null:
			var direct_space := get_world_2d().direct_space_state

			var params := PhysicsShapeQueryParameters2D.new()
			params.shape = CircleShape2D.new()
			params.shape.radius = 3
			params.collide_with_areas = false
			params.collide_with_bodies = true
			params.transform = Transform2D(0, get_global_mouse_position())

			var result := direct_space.intersect_shape(params)
			for found in result:
				if found.collider is Item and found.collider in items_in_radius:
					current_item = found.collider
					break
		else:
			current_item = null


func _on_body_entered(body: Node2D) -> void:
	if body is Item:
		items_in_radius.append(body as Item)

func _on_body_exit(body: Node2D) -> void:
	if body in items_in_radius:
		items_in_radius.erase(body as Item)
