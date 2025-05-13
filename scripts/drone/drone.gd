class_name Drone
extends RigidBody2D

@export var fly_up_max_speed: float = 500.0
@export var vertical_acceleration: float = 250.0
@export var vertical_drop_percentage_gravity := 0.5
@export var vertical_stabilization_accel: float = 50.0

@export var horizontal_acceleration: float = 150.0
@export var horizontal_max_speed: float = 250.0
@export var horizontal_stabilization_accel: float = 100.0
@export var horizontal_pivot_point: Vector2 = Vector2(0, -0.1)
@export var horizontal_torque_stabilization: float = 50.0

@export var rotation_stabilization_threshold: float = 170
@export var disable_velocity_threshold: float = 20

@export var sparks_velocity_threshold: float = 100

@export var battery_drain: float = .1
@export var battery_drain_item: float = .2

@onready var disable_timer: Timer = $DisableTimer
@onready var spark_particles: GPUParticles2D = $SparkParticles
@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var item_manager: ItemManager = $ItemManager

var prev_velocity: Vector2
var dead := false

func _ready() -> void:
	animation_player.play("fly")

func _process(delta: float) -> void:
	health_component.health -= battery_drain * delta
	
	if item_manager.current_item != null:
		health_component.health -= (battery_drain_item * item_manager.current_item.mass) * delta

	if not disable_timer.is_stopped() or dead:
		smoke_particles.emitting = true
		return

	if smoke_particles.emitting:
		smoke_particles.emitting = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for collision in state.get_contact_count():
		_handle_collision(state, collision)
	
	if state.get_contact_count() == 0:
		spark_particles.emitting = false

	prev_velocity = state.linear_velocity
	
	if disable_timer.is_stopped() and not dead:
		_movement(state)
	
func _movement(state: PhysicsDirectBodyState2D) -> void:
	var force := Vector2.ZERO
	var horizontal_force := Vector2.ZERO

	if Input.is_action_pressed("fly_up") and abs(state.linear_velocity.y) < fly_up_max_speed:
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
		_adjust_torque()
	elif linear_velocity.x < 0:
		horizontal_force += mass * Vector2(horizontal_stabilization_accel, 0)
		_adjust_torque()

	if linear_velocity.length() <= 1:
		animation_player.pause()
	else:
		animation_player.play()

	apply_central_force(force)
	apply_force(horizontal_force, horizontal_pivot_point)

func _handle_collision(
	state: PhysicsDirectBodyState2D, collision_idx: int
) -> void:
	var delta_velocity := state.linear_velocity - prev_velocity

	if delta_velocity.length() >= disable_velocity_threshold:
		disable_timer.start()

	if linear_velocity.length() < sparks_velocity_threshold:
		spark_particles.emitting = false
		return

	var normal := state.get_contact_local_normal(collision_idx)
	var factor := linear_velocity.length() / sparks_velocity_threshold

	spark_particles.rotation = normal.angle() + PI

	spark_particles.process_material.initial_velocity_min = linear_velocity.x * factor
	spark_particles.process_material.initial_velocity_max = linear_velocity.y * factor
	
	spark_particles.emitting = true

func _adjust_torque() -> void:
	var direction := Vector2.RIGHT.dot(global_transform.y)
	apply_torque(direction * horizontal_torque_stabilization)

func _on_health_component_died() -> void:
	spark_particles.emitting = true
	dead = true
