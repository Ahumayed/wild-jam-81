extends Node2D

@export var spawn_count = 50
var item: PackedScene

func _ready() -> void:
	item = preload("res://scenes/popcorn.tscn")
	randomize()  # Initialize random number generator

func _process(delta: float) -> void:
	if spawn_count > 0:
		var instance: RigidBody2D = item.instantiate()
		add_child(instance)
		spawn_count -= 1

		# Apply random impulse
		var angle = randf() * TAU  # Random angle 0 - 2π
		var strength = randf_range(100, 300)  # Customize as needed
		var impulse = Vector2(cos(angle), sin(angle)) * strength
		instance.apply_impulse(impulse)
