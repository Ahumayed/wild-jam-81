class_name Drone
extends RigidBody2D

@export_category("Movement Variables")
@export var fly_up_max_speed: float = 500.0
@export var vertical_acceleration: float = 250.0
@export var vertical_drop_percentage_gravity := 0.5
@export var vertical_stabilization_accel: float = 50.0

@export var horizontal_acceleration: float = 150.0
@export var horizontal_max_speed: float = 250.0
@export var horizontal_stabilization_accel: float = 100.0
@export var horizontal_pivot_point: Vector2 = Vector2(0, -0.1)

@export var disable_velocity_threshold: float = 20

@export_category("Visual variables")
@export var sparks_velocity_threshold: float = 20

@onready var disable_timer: Timer = $DisableTimer
@onready var spark_particles: GPUParticles2D = $SparkParticles
@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite

var prev_velocity: Vector2

func _ready() -> void:
	animation_player.play("fly")

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for collision in state.get_contact_count():
		_handle_collision(state, state.get_contact_collider_position(collision))

	prev_velocity = state.linear_velocity

	if not disable_timer.is_stopped():
		animation_player.pause()
		smoke_particles.emitting = true
		return
	
	if smoke_particles.emitting:
		smoke_particles.emitting = false
	
	_movement(state)

	
func _movement(state: PhysicsDirectBodyState2D) -> void:
	var force := Vector2.ZERO
	var horizontal_force := Vector2.ZERO

	if Input.is_action_pressed("fly_up") and state.linear_velocity.y < fly_up_max_speed:
		force -= mass * Vector2(0, vertical_acceleration)
	elif state.linear_velocity.y < 0:
		force += mass * Vector2(0, vertical_stabilization_accel)
	
	# Counteract gravity unless they want to fall
	if not Input.is_action_pressed("fly_down"):
		force -= state.total_gravity
	
	if Input.is_action_pressed("fly_down"):
		force -= state.total_gravity * vertical_drop_percentage_gravity
	elif state.linear_velocity.y > 0:
		force -= mass * Vector2(0, vertical_stabilization_accel)
	
	var can_move_horizontal: bool = abs(linear_velocity.x) < horizontal_max_speed
	if Input.is_action_pressed("right") and can_move_horizontal:
		horizontal_force += mass * Vector2(horizontal_acceleration, 0)
		sprite.flip_h = true
	elif Input.is_action_pressed("left") and can_move_horizontal:
		horizontal_force -= mass * Vector2(horizontal_acceleration, 0)
		sprite.flip_h = false
	elif linear_velocity.x > 0:
		horizontal_force -= mass * Vector2(horizontal_stabilization_accel, 0)
	elif linear_velocity.x < 0:
		horizontal_force += mass * Vector2(horizontal_stabilization_accel, 0)

	if linear_velocity.length() <= 1:
		animation_player.pause()
	else:
		animation_player.play()

	apply_central_force(force)
	apply_force(horizontal_force, horizontal_pivot_point)

func _handle_collision(
	state: PhysicsDirectBodyState2D, collision_pos: Vector2
) -> void:
	var delta_velocity := state.linear_velocity - prev_velocity

	if delta_velocity.length() >= disable_velocity_threshold:
		disable_timer.start()
	
