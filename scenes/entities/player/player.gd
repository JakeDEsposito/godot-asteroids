extends RigidBody2D

const ROTATE_SPEED: float = 4.5
const MOVE_SCALER: float = 0.6

@onready var muzzle: Marker2D = %Muzzle

@onready var engine_audio: AudioStreamPlayer = %EngineAudio
@onready var impact_audio: AudioStreamPlayer = %ImpactAudio
@onready var force_field_audio: AudioStreamPlayer = %ForceFieldAudio
@onready var explosion_audio: AudioStreamPlayer = %ExplosionAudio
@onready var laser_audio: AudioStreamPlayer = $LaserAudio

const bullet_scene = preload("res://scenes/entities/bullet/bullet.tscn")

signal health_updated(new_health: int)
var health: int = 3:
	set(new_health):
		health = new_health
		health_updated.emit(new_health)

signal score_updated(new_score: int)
var score: int = 0:
	set(new_score):
		score = new_score
		score_updated.emit(new_score)


var is_invulnerable: bool = false
var can_shoot: bool = true

func _physics_process(dt: float) -> void:
	move(dt)
	
	# Change pitch of engine audio to show ships speed
	engine_audio.pitch_scale = clamp(linear_velocity.length() / 20, 0.01, 3)
	
	# The engine audio below 0.2 pitch scale sounds wierd so stop the engine audio if it is below that
	engine_audio.stream_paused = engine_audio.pitch_scale < 0.2
	
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		
		shoot()
		
		get_tree().create_timer(0.2, false).timeout.connect(func(): can_shoot = true)

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

func shoot() -> void:
	var bullet: RigidBody2D = bullet_scene.instantiate()
	
	bullet.transform = muzzle.global_transform
	bullet.apply_force(Vector2(0, -20000).rotated(bullet.rotation))
	bullet.body_entered.connect(bullet_hit)
	
	owner.add_child(bullet)
	
	laser_audio.play()

func bullet_hit(body: Node) -> void:
	if (body.is_in_group("asteroids")):
		score += 1

func _on_body_entered(body: Node) -> void:
	take_hit()
