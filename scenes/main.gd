extends Node2D

const radius_increment = 20
const FORCE = 100.0

var radius = 100.0

@export_enum("IDLE", "FORCE", "COLLECT") var mouse_state = "IDLE"

@onready var score_audio_player: AudioStreamPlayer = $ScoreAudioPlayer
@onready var drop_point: Node2D = $DropPoint
@onready var control_area: Area2D = $ControlArea
@onready var pause_menu: AspectRatioContainer = $PauseMenu
@onready var score_label: Label = $Score
@onready var best_label: Label = $Best

var score = 0
var best_score = 0

func _ready() -> void:
	best_score = Global.score
	best_label.text = "Score: %s" % str(best_score)
	
func _draw():
	var mouse_pos = get_global_mouse_position()
	var color = Color(1,1,1,1)
	if mouse_state == "FORCE":
#		blue
		color = Color(0, 0, 1, 1)
	if mouse_state == "COLLECT":
#		red
		color = Color(1,0,0,1)
		
	draw_circle(mouse_pos, radius, color, false, 5)

func _process(delta: float) -> void:
	queue_redraw()
	var pos = get_viewport().get_mouse_position()
	var bodies = get_bodies_in_radius(pos, radius)
	
	if not bodies.is_empty():
		if mouse_state == "FORCE":
			apply_force_to_bodies(bodies, pos)
			
		if mouse_state == "COLLECT":
			collect_bodies(bodies, pos)

func get_bodies_in_radius(center: Vector2, radius: float) -> Array:
	var space_state = get_world_2d().direct_space_state

	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius

	var transform = Transform2D.IDENTITY
	transform.origin = center

	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(circle_shape)
	query.transform = transform
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var results = space_state.intersect_shape(query, 32)  # Max 32 results
	var bodies := []
	var valid_bodies = control_area.get_overlapping_bodies()
	for result in results:
		if result.collider is RigidBody2D and result.collider in valid_bodies:
			bodies.append(result.collider)

	return bodies

func apply_force_to_bodies(bodies: Array, origin: Vector2):
	for body: RigidBody2D in bodies:
		var direction = (body.global_position - origin).normalized()
		var force = direction * FORCE
		var offset = origin - body.global_position
		body.apply_impulse(force)

func collect_bodies(bodies: Array, origin: Vector2):
	for body: Popcorn in bodies:
		body.collect_popcorn(drop_point.global_position)
		
		if body.state == "RAW":
			score -= 3
		
		if body.state == "POPCORN":
			score += 5
		
		if body.state == "BURNT":
			score -= 5
		
	score_label.text = "Score: %s" % str(score)
	if score > best_score:
		Global.score = score
		best_score = score
		best_label.text = "Best: %s" % str(best_score)
		
	var stream = load("res://assets/audio/%s.ogg" % str(randi_range(1, 9)))
	score_audio_player.stream = stream
	score_audio_player.play()
		
func _input(event: InputEvent) -> void:
	if event.is_action("enlarge_circle"):
		var new_r = radius + radius_increment
		radius = clampf(new_r, 10, 300)

	if event.is_action("shrink_circle"):
		var new_r = radius - radius_increment
		radius = clampf(new_r, 10, 300)
	
	if event.is_action_released("collect", true):
		mouse_state = "FORCE"
	
	if event.is_action_pressed("collect", true):
		mouse_state = "COLLECT"
	if event.is_action("toggle_pause"):
		_toggle_pause()

func _toggle_pause():
	Global.toggle_pause()
	pause_menu.visible = !pause_menu.visible
	
func _on_pause_button_pressed() -> void:
	_toggle_pause()


func _on_resume_button_pressed() -> void:
	_toggle_pause()


func _on_exit_button_pressed() -> void:
	Global.change_scene("res://scenes/main_menu.tscn")


func _on_restart_button_pressed() -> void:
	Global.restart_scene()
