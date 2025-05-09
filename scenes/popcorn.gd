extends RigidBody2D
class_name Popcorn

@onready var burning_timer: Timer = $BurningTimer
@onready var cooking_timer: Timer = $CookingTimer
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var oil_bubbles: CPUParticles2D = $OilBubbles
@onready var burn_smoke: CPUParticles2D = $BurnSmoke
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var reset_state = false
var moveVector: Vector2
var state = "RAW"
var is_on_heat := false


func _ready() -> void:
	cooking_timer.wait_time = randf_range(3, 10)
	burning_timer.wait_time = randf_range(11, 15)


func _process(_delta: float) -> void:
	process_heat()

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(0.0, moveVector)
		reset_state = false

func collect_popcorn(targetPos: Vector2):
	moveVector = targetPos
	reset_state = true
	var factor = 0.5
	sprite.scale = sprite.scale
	collision_shape_2d.scale *= factor

func process_heat() -> void:

	if is_on_heat:
		if state == "RAW":
			cooking_timer.start()
			state = "KERNEL"

		if state == "KERNEL":
			cooking_timer.paused = false
			oil_bubbles.emitting = true

		if state == "POPCORN":
			burning_timer.paused = false
			oil_bubbles.emitting = false
			burn_smoke.emitting = true
	else:
		cooking_timer.paused = true
		burning_timer.paused = true
		oil_bubbles.emitting = false
		burn_smoke.emitting = false


func on_in_heat() -> void:
	is_on_heat = true

func on_off_heat() -> void:
	is_on_heat = false

func _on_cooking_timer_timeout() -> void:
	oil_bubbles.emitting = false
	if state == "KERNEL":
		pop()

func _on_burning_timer_timeout() -> void:
	if state == "POPCORN":
		burn()
		burn_smoke.emitting = false

func pop():
	burning_timer.start()
	burning_timer.paused = false
	burn_smoke.emitting = true
	state = "POPCORN"
	collision_shape_2d.scale = Vector2.ONE
	var number = str(randi_range(1, 4))
	var texture = load("res://assets/sprites/popcorn (%s).png" % number)
	sprite.texture = texture
	audio_stream_player_2d.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player_2d.play()

func burn():
	state = "BURNT"
	var shader_material := sprite.material as ShaderMaterial
	shader_material.set_shader_parameter("darkness", 0.75)
