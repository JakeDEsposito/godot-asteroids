extends RigidBody2D

const ROTATE_SPEED: float = 4.5
const MOVE_SCALER: float = 0.6

@onready var engine_audio: AudioStreamPlayer = %EngineAudio
@onready var impact_audio: AudioStreamPlayer = %ImpactAudio
@onready var force_field_audio: AudioStreamPlayer = %ForceFieldAudio
@onready var explosion_audio: AudioStreamPlayer = %ExplosionAudio
@onready var laser_audio: AudioStreamPlayer = $LaserAudio

var health: int = 3
var is_invulnerable: bool = false

func _physics_process(dt: float) -> void:
	move(dt)
	
	# Change pitch of engine audio to show ships speed
	engine_audio.pitch_scale = clamp(linear_velocity.length() / 20, 0.01, 3)
	
	# The engine audio below 0.2 pitch scale sounds wierd so stop the engine audio if it is below that
	engine_audio.stream_paused = engine_audio.pitch_scale < 0.2

func move(dt: float) -> void:
	# Forward Movement
	apply_impulse(Vector2.UP.rotated(rotation) * MOVE_SCALER * Input.get_action_strength("forward"))
	
	# Rotation Movement
	rotation += Input.get_axis("left", "right") * ROTATE_SPEED * dt
	
	# Clear Angular Velocity
	angular_velocity = 0

func take_hit() -> void:
	if is_invulnerable:
		# TODO: Create a force field visual and make it shimmer when it takes a hit.
		force_field_audio.play()
		return
	
	health -= 1
	
	if health > 0:
		impact_audio.play()
		
		is_invulnerable = true
		
		get_tree().create_timer(5, false).timeout.connect(func(): is_invulnerable = false)
	else:
		engine_audio.stop()
		explosion_audio.play()
		
		# TODO: Create ship parts that get thrown around when ship dies
		
		await explosion_audio.finished
		#queue_free
		
		# TODO: Move to game over screen.

func _on_body_entered(body: Node) -> void:
	print(collision_layer)
	take_hit()
