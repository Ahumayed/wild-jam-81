class_name ItemManager
extends Area2D

@export var min_radius: float = 30.0
@export var target_velocity: float = 30.0
@export var tolerance: float = 5.0
@export var stiffness: float = 30.0
@export var damping: float = 6.0
@export var torque: float = 10.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var radius: float = collision_shape.shape.radius

var current_item: Item = null
var items_in_radius: Array[Item] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)

func _process(_delta: float) -> void:
	queue_redraw()
	if Input.is_action_just_pressed("grab"):
		if current_item == null:
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
					_grab_item(found.collider)
					break
		else:
			_drop_item()
	
	_handle_item()

func _handle_item() -> void:
	if current_item == null:
		return

	if Input.is_action_pressed("rotate_right"):
		current_item.apply_torque(torque)
	elif Input.is_action_pressed("rotate_left"):
		current_item.apply_torque(-torque)
	
	if Input.is_action_just_pressed("use_item"):
		current_item.used.emit()
	
	var item_dst := current_item.global_position.distance_to(global_position)

	if item_dst - tolerance > radius:
		_drop_item()
		return

	var mouse_pos := get_global_mouse_position()
	var dst_to_mouse := clampf(global_position.distance_to(mouse_pos), min_radius, radius)
	var dir_to_mouse := global_position.direction_to(mouse_pos)
	var target_pos := global_position + (dir_to_mouse * dst_to_mouse)

	var dir := current_item.global_position.direction_to(target_pos)
	var dst := current_item.global_position.distance_to(target_pos)

	var velocity := current_item.linear_velocity.length()
	if dst < tolerance and velocity < 5.0:
		current_item.linear_velocity = Vector2.ZERO
		current_item.angular_velocity = 0.0
		return

	var force := dir * dst * stiffness - current_item.linear_velocity * damping

	current_item.apply_force(force)

func _grab_item(item: Item) -> void:
	if current_item != null:
		_drop_item()
	current_item = item
	item.grabbed.emit()

func _drop_item() -> void:
	current_item.released.emit()
	current_item = null

func _draw() -> void:
	if current_item != null:
		draw_line(to_local(global_position), to_local(current_item.global_position), Color.RED, 5)

func _on_body_entered(body: Node2D) -> void:
	if body is Item:
		items_in_radius.append(body as Item)

func _on_body_exit(body: Node2D) -> void:
	if body is Item and (body as Item) in items_in_radius:
		items_in_radius.erase(body as Item)
