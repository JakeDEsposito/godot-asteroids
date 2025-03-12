extends RigidBody2D

const RESOLUTION: int = 12
const ANGLE_STEP: float = TAU / RESOLUTION

const MAX_ASTEROID_SIZE: int = 2

@export_range(0, MAX_ASTEROID_SIZE) var size: int = randi_range(1, MAX_ASTEROID_SIZE)

@onready var shape: Line2D = %Shape
@onready var collision: CollisionShape2D = %Collision
@onready var explosion_audio: AudioStreamPlayer = %ExplosionAudio

func _ready() -> void:
	shape.clear_points()
	
	for i: int in RESOLUTION:
		var theta: float = i * ANGLE_STEP
		var point: Vector2 = Vector2(cos(theta), sin(theta)) # TODO: This can probably be simplified by using Vector2.rotated
		
		if i % 3 == 0:
			# x controls depth of crater.
			# y controls shift of crater.
			var crater: Vector2 = Vector2(randf_range(0.2, 0.5), randf_range(-0.4, 0.4))
			
			point -= crater.rotated(theta)
		
		shape.add_point(point * 10)
	
	shape.scale = Vector2.ONE * size
	collision.scale = Vector2.ONE * size

func take_hit() -> void:
	size -= 1
	
	explosion_audio.play()
	
	if size > 0:
		var meteoroids_count: int = randi_range(1, 3)
		var angle_step: float = TAU / meteoroids_count
		
		for i: int in meteoroids_count:
			var theta: float = i * angle_step
			
			var asteroid: RigidBody2D = duplicate()
			asteroid.global_position = Vector2(cos(theta), sin(theta)) * size * 10 + global_position # TODO: This can probably be simplified by using Vector2.rotated
			asteroid.apply_force(Vector2.UP.rotated(theta) * randf_range(50, 500))
			
			get_parent().call_deferred("add_child", asteroid)
	
	hide()
	collision.call_deferred("set_disabled", true)
	
	explosion_audio.finished.connect(func() -> void: queue_free())

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("asteroids"):
		take_hit()
