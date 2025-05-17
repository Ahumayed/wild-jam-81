class_name Enemy
extends CharacterBody2D

@export var player_node: Node2D
@export var detection_radius: float = 100.0
@export var touching_radius: float = 15
@export var move_speed: float = 100.0
@export var los_collision_mask: int = 1

@onready var blackboard: Blackboard = $Blackboard

var is_clinging: bool = false
var is_stunned: bool = false
var stunned_timer: float = 0.0
const STUN_DURATION: float = 2.0

func can_see_player() -> bool:
	if player_node == null:
		return false
	
	# Distance check
	var distance = global_position.distance_to(player_node.global_position)
	if distance > detection_radius:
		return false

	# Line of sight check
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player_node.global_position, los_collision_mask, [self])
	var result = space_state.intersect_ray(query)

	# If result is empty or directly hits player, LOS is clear
	return result.is_empty() or result["collider"] == player_node

func is_touching_player() -> bool:
	var distance = global_position.distance_to(player_node.global_position)
	if distance > touching_radius:
		return false
	
	else:
		return true

func move_toward_player() -> void:

	var direction = (player_node.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

func cling_to_player() -> void:
	var direction = (player_node.global_position - global_position).normalized()
	velocity = direction * move_speed * 100 #Very high speed
	move_and_slide()

func _physics_process(delta):
	if is_stunned:
		stunned_timer -= delta
		if stunned_timer <= 0.0:
			is_stunned = false
		return  # Skip AI logic while stunned

func on_player_attack():
	if is_clinging:
		is_stunned = true
		is_clinging = false
		stunned_timer = STUN_DURATION
		velocity = Vector2.ZERO  # Stop movement if needed
